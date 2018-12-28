FROM openjdk:8-alpine AS base

ENV GRADLE_HOME /root/.gradle
RUN mkdir -p $GRADLE_HOME && \
    echo "org.gradle.jvmargs=-Xmx4000M" >> $GRADLE_HOME/gradle.properties && \
    echo "org.gradle.daemon=false" >> $GRADLE_HOME/gradle.properties && \
    echo "org.gradle.parallel=true" >> $GRADLE_HOME/gradle.properties && \
    echo "org.gradle.parallel.intra=true" >> $GRADLE_HOME/gradle.properties && \
    echo "org.gradle.caching=true" >> $GRADLE_HOME/gradle.properties && \
    echo "android.enableBuildCache=true" >> $GRADLE_HOME/gradle.properties && \
    echo "kapt.use.worker.api=true" >> $GRADLE_HOME/gradle.properties

ARG ANDROID_SDK_LICESNSE=d56f5187479451eabf01fb78af6dfcb131a6481e
ENV ANDROID_HOME /home/Android/sdk
RUN mkdir -p "$ANDROID_HOME/licenses" || true && \
    echo "$ANDROID_SDK_LICESNSE" > "$ANDROID_HOME/licenses/android-sdk-license"

ARG GLIBC_VERSION=2.28-r0
RUN apk add --no-cache --virtual=.build-dependencies wget unzip ca-certificates bash && \
	wget https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub && \
	wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk -O /tmp/glibc.apk && \
	wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk -O /tmp/glibc-bin.apk && \
	apk add --no-cache /tmp/glibc.apk /tmp/glibc-bin.apk && \
	rm -rf /tmp/* && \
	rm -rf /var/cache/apk/*

# ----------------------------------------------------------------------------------------------------------------------

FROM base AS cache

WORKDIR "/home/src"
# Copy all source into the container, so it can be built.
COPY . .
# Trigger gradle, so that we cache the gradle wrapper and the android sdk.
RUN ./gradlew dependencies

# ----------------------------------------------------------------------------------------------------------------------

FROM base
COPY --from=cache $ANDROID_HOME $ANDROID_HOME
COPY --from=cache $GRADLE_HOME $GRADLE_HOME

WORKDIR "/home/src"

# Image builds would typically look like `docker build -t android-gradle .`
# Image runs would typically look like `docker run --rm -v "$PWD":/home/src android-gradle:latest ./gradlew :app:assembleDebug`

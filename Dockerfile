FROM openjdk:8-alpine AS base

ENV GRADLE_HOME=/root/.gradle \
    ANDROID_HOME=/home/Android/sdk \
    GLIBC_VERSION=2.29-r0

# Configure gradle.
RUN mkdir -p $GRADLE_HOME && \
    echo "org.gradle.jvmargs=-Xmx4000M" >> $GRADLE_HOME/gradle.properties && \
    echo "org.gradle.parallel=true" >> $GRADLE_HOME/gradle.properties && \
    echo "org.gradle.parallel.intra=true" >> $GRADLE_HOME/gradle.properties && \
    echo "org.gradle.caching=true" >> $GRADLE_HOME/gradle.properties && \
    echo "android.enableBuildCache=true" >> $GRADLE_HOME/gradle.properties && \
    echo "kapt.use.worker.api=true" >> $GRADLE_HOME/gradle.properties && \
    # Add Android sdk licenses.
    mkdir -p "$ANDROID_HOME/licenses" || true && \
    echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "$ANDROID_HOME/licenses/android-sdk-license" && \
    # Configure java dependencies to work well with gradle/android.
    apk add --no-cache --virtual=.build-dependencies wget unzip ca-certificates bash && \
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

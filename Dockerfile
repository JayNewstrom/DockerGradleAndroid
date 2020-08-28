FROM openjdk:8-alpine AS base

ENV GRADLE_HOME=/root/.gradle \
    ANDROID_HOME=/home/Android/sdk \
    GLIBC_VERSION=2.30-r0

# Add Android sdk licenses.
RUN mkdir -p "$ANDROID_HOME/licenses" || true \
    && echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "$ANDROID_HOME/licenses/android-sdk-license" \
    && echo "export ANDROID_HOME=$ANDROID_HOME" >> /root/.profile \
    && echo "export GRADLE_HOME=$GRADLE_HOME" >> /root/.profile \
    # Configure java dependencies to work well with gradle/android.
    && apk add --no-cache --update wget unzip ca-certificates bash rsync openssh \
    && rm -f /etc/ssh/ssh_host_rsa_key \
    && echo "root:root" | chpasswd \
	&& wget https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub \
	&& wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk -O /tmp/glibc.apk \
	&& wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk -O /tmp/glibc-bin.apk \
	&& apk add --no-cache /tmp/glibc.apk /tmp/glibc-bin.apk \
	&& rm -rf /tmp/* \
	&& rm -rf /var/cache/apk/*

# ----------------------------------------------------------------------------------------------------------------------

FROM base AS cache

WORKDIR "/home/src"
# Copy all source into the container, so it can be built.
COPY android-sample/ .
# Trigger gradle, so that we cache the gradle wrapper, the android sdk, and the build tools.
RUN ./gradlew :app:assembleDebug --no-build-cache && ./gradlew --stop && rm -rf $GRADLE_HOME/daemon

# ----------------------------------------------------------------------------------------------------------------------

FROM base

# S6 Overlay.
ADD https://github.com/just-containers/s6-overlay/releases/download/v2.0.0.1/s6-overlay-amd64.tar.gz /tmp/
RUN gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

COPY --from=cache $ANDROID_HOME $ANDROID_HOME
COPY --from=cache $GRADLE_HOME $GRADLE_HOME

COPY root/ /

WORKDIR "/home/src"

ENTRYPOINT ["/init"]

# Image builds would typically look like `docker build -t android-gradle .`
# Image runs would typically look like `docker run --rm -v "$PWD":/home/src android-gradle:latest ./gradlew :app:assembleDebug`

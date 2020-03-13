#!/usr/bin/env bash

set -o errexit

PUSH=$1

source versions.sh

./gradlew wrapper --gradle-version=${GRADLE_VERSION} # First run changes `gradle/wrapper/gradle-wrapper.properties`.
./gradlew wrapper --gradle-version=${GRADLE_VERSION} # Second run regenerates the wrapper.

sed -i "/androidGradlePluginVersion=/ s/=.*/=${AGP_VERSION}/" gradle.properties

VERSION_TAG="gradle-${GRADLE_VERSION}_agp-${AGP_VERSION}"

# Docker.
docker build -t alpine-android-gradle .
docker tag alpine-android-gradle:latest jaynewstrom/alpine-gradle-android:${VERSION_TAG}
if [[ $PUSH == 'true' ]]; then
  docker push jaynewstrom/alpine-gradle-android:${VERSION_TAG}
fi

docker build -t remote-build --build-arg CONTAINER_TAG=${VERSION_TAG} -f remoteBuild/Dockerfile remoteBuild/.
docker tag remote-build:latest jaynewstrom/alpine-gradle-android-remote-build:${VERSION_TAG}
if [[ $PUSH == 'true' ]]; then
  docker push jaynewstrom/alpine-gradle-android-remote-build:${VERSION_TAG}
fi

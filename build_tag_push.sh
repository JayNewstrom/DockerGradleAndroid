#!/usr/bin/env bash

set -o errexit

die () {
    echo >&2 "$@"
    exit 1
}

[[ "$#" -eq 2 ]] || die "2 arguments required, $# provided. 1st argument should be gradle version. 2nd argument should be android gradle plugin version."

GRADLE_VERSION=$1
AGP_VERSION=$2

./gradlew wrapper --gradle-version=${GRADLE_VERSION} # First run changes `gradle/wrapper/gradle-wrapper.properties`.
./gradlew wrapper --gradle-version=${GRADLE_VERSION} # Second run regenerates the wrapper.

gsed -i "/androidGradlePluginVersion=/ s/=.*/=${AGP_VERSION}/" gradle.properties

VERSION_TAG="gradle-${GRADLE_VERSION}_agp-${AGP_VERSION}"
# Docker.
docker build -t alpine-android-gradle .
docker tag alpine-android-gradle:latest jaynewstrom/alpine-gradle-android:${VERSION_TAG}
docker push jaynewstrom/alpine-gradle-android:${VERSION_TAG}

docker build -t remote-build --build-arg CONTAINER_TAG=${VERSION_TAG} -f remoteBuild/Dockerfile remoteBuild/.
docker tag remote-build:latest jaynewstrom/alpine-gradle-android-remote-build:${VERSION_TAG}
docker push jaynewstrom/alpine-gradle-android-remote-build:${VERSION_TAG}

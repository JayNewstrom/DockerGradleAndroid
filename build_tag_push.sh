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

# Docker.
docker build -t apline-android-gradle .
docker tag  apline-android-gradle:latest jaynewstrom/alpine-gradle-android:gradle-${GRADLE_VERSION}_agp-${AGP_VERSION}
docker push jaynewstrom/alpine-gradle-android:gradle-${GRADLE_VERSION}_agp-${AGP_VERSION}

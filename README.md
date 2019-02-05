Overview
========

Dockerhub: https://hub.docker.com/r/jaynewstrom/alpine-gradle-android

Build
=====
`docker build -t apline-android-gradle .`

Tag
===
`docker tag docker tag  apline-android-gradle:latest jaynewstrom/alpine-gradle-android:gradle-${GRADLE_VERSION}_agp-${AGP_VERSION}`

Push
====
`docker push jaynewstrom/alpine-gradle-android:gradle-${GRADLE_VERSION}_agp-${AGP_VERSION}`

Run
===
`docker run --rm -v "$PWD":/home/src alpine-gradle-android:latest ./gradlew assemble`

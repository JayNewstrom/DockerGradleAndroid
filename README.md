## Dockerhub
Use from [Dockerhub](https://hub.docker.com/r/jaynewstrom/alpine-gradle-android)

`docker run --rm -v "$PWD":/home/src jaynewstrom/alpine-gradle-android:latest ./gradlew assemble`

## Local Development

#### Build
`docker build -t alpine-gradle-android .`

#### Tag
`docker tag  alpine-gradle-android:latest jaynewstrom/alpine-gradle-android:gradle-${GRADLE_VERSION}_agp-${AGP_VERSION}`

#### Push
`docker push jaynewstrom/alpine-gradle-android:gradle-${GRADLE_VERSION}_agp-${AGP_VERSION}`

#### Run
`docker run --rm -v "$PWD":/home/src alpine-gradle-android:latest ./gradlew assemble`

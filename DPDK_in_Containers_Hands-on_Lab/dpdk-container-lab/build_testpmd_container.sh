#!/bin/bash

DOCKER_BUILD_DIR="$(pwd)/docker-build/testpmd"
DOCKER_TAG="ses2017/testpmd1"

cd $DOCKER_BUILD_DIR

docker build . -t $DOCKER_TAG

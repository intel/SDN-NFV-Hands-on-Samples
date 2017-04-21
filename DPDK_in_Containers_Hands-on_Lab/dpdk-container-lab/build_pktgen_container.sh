#!/bin/bash

DOCKER_BUILD_DIR="$(pwd)/docker-build/pktgen"
DOCKER_TAG="ses2017/pktgen1"

cd $DOCKER_BUILD_DIR

docker build . -t $DOCKER_TAG

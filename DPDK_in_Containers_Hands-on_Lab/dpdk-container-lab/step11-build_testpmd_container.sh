#!/bin/bash

DOCKER_BUILD_DIR="$TRAINING_DIR/docker-build/testpmd"
DOCKER_TAG="dpdk-containers/testpmd"

cd $DOCKER_BUILD_DIR

docker build . -t $DOCKER_TAG

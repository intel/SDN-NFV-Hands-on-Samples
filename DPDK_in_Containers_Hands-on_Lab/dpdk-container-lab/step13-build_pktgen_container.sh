#!/bin/bash

DOCKER_BUILD_DIR="$TRAINING_DIR/docker-build/pktgen"
DOCKER_TAG="dpdk-containers/pktgen"

cd $DOCKER_BUILD_DIR

docker build . -t $DOCKER_TAG

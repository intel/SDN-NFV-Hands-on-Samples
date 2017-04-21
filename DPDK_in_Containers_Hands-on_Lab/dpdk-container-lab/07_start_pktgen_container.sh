#!/bin/bash

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

export DOCKER_TAG="ses2017/pktgen1"

CMD="docker run -tiv /mnt/huge:/mnt/huge -v /usr/local/var/run/openvswitch:/var/run/openvswitch --privileged $DOCKER_TAG"
echo "Running $CMD"
$CMD

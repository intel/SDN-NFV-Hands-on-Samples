#!/bin/bash

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

export DOCKER_TAG="dpdk-containers/pktgen"

echo "Launching docker container in privileged mode with access to host hugepages and OVS DPDK sockets"
CMD="docker run -tiv /mnt/huge:/mnt/huge -v /usr/local/var/run/openvswitch:/var/run/openvswitch --privileged $DOCKER_TAG"
echo "Running $CMD"
$CMD

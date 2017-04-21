#!/bin/bash

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

if [ "$DPDK_DIR" == "" ]; then
	echo "Sorry, DPDK_DIR env var has not been set to root of DPDK src tree"
	exit 1
fi

if [ "$DPDK_BUILD" == "" ]; then
	echo "Sorry, DPDK_BUILD env var has not been set to DPDK target build env"
	exit 1
fi


#echo "Making sure that DPDK has been built"
#cd $DPDK_DIR
#make config O=$DPDK_BUILD T=$DPDK_BUILD
#cd $DPDK_BUILD
#make -j

echo "Building pktgen..."
export PKTGEN_DIR=/usr/src/pktgen
cd $PKTGEN_DIR
make -j

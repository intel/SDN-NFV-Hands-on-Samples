#!/bin/bash

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

if [ "$DPDK_DIR" == "" ]; then
	echo "Sorry, DPDK_DIR has not been defined."
	exit 1
fi

if [ "$DPDK_BUILD" == "" ]; then
	echo "Sorry, DPDK_BUILD has not been defined."
	exit 1
fi

if [ "$OVS_DIR" == "" ]; then
	echo "Sorry, OVS_DIR has not been defined."
	exit 1
fi


cd $OVS_DIR
echo "Running running the autoconf magic script"
./boot.sh
echo "Configuring OVS with DPDK support"
CFLAGS='-march=native' ./configure --with-dpdk=$DPDK_DIR/$DPDK_BUILD

echo "Building OVS"
make -j8

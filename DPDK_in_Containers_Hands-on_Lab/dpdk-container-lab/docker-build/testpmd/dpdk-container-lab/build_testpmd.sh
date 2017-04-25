#!/bin/bash

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

if [ "$RTE_SDK" == "" ]; then
	echo "Sorry, RTE_SDK env var has not been set to root of DPDK src tree"
	exit 1
fi

if [ "$RTE_TARGET" == "" ]; then
	echo "Sorry, RTE_TARGET env var has not been set to DPDK target build env"
	exit 1
fi

#echo "Making sure that DPDK has been built"
#cd $RTE_SDK
#make config O=$RTE_TARGET T=$RTE_TARGET
#cd $RTE_TARGET
#make -j8

echo "Building testpmd..."
cd $RTE_SDK/app/test-pmd
make -j8

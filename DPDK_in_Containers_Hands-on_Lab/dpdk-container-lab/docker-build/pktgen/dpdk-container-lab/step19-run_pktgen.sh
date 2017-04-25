#!/bin/bash

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

if [ "$PKTGEN_DIR" == "" ]; then
	echo "Sorry, PKTGEN_DIR env var has not been set to root of PKTGEN src tree"
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

#-P: Promiscuous mode
#-T: Color terminal output
#-m "0.0,4.1" (core.port): core 0: port 0 rx/tx; core 4: port 1 rx/tx
PKTGEN_PARAMS='-T -P -m "0.0,4.1"'

cd $PKTGEN_DIR

CMD="./app/app/$DPDK_BUILD/pktgen $DPDK_PARAMS -- $PKTGEN_PARAMS"
echo "Launching pktgen...CMD=$CMD"
$CMD

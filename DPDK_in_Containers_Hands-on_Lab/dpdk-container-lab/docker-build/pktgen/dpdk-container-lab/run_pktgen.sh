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

#-c 0x19: DPDK can run on core 0,3-4: (0b0001 1001)
#--master-lcore 3: make the pktgen dpdk thread run on core 3 (0b1000)
#-n 1: we only have one memory bank in this VM
#--socket-mem 1024: use 1GB per socket
#--file-prefix pktgen: "pktgen" will be appended to hugepage memory files used by this process
#--no-pci don't look for any PCI devices 
#--vdev 'virtio_user0,mac=00:00:00:00:00:00,path=/var/run/openvswitch/vhost-user0' 
#--vdev 'virtio_user1,mac=00:00:00:00:00:01,path=/var/run/openvswitch/vhost-user1'
DPDK_PARAMS_VIRTIO="-c 0x19 --master-lcore 3 -n 1 --socket-mem 1024 --file-prefix pktgen --no-pci --vdev=net_virtio_user0,mac=00:00:00:00:00:00,path=/var/run/openvswitch/vhost-user0 --vdev=net_virtio_user1,mac=00:00:00:00:00:01,path=/var/run/openvswitch/vhost-user1"

echo "Using virtio with DPDK"
DPDK_PARAMS=$DPDK_PARAMS_VIRTIO

cd $PKTGEN_DIR

CMD="./app/app/$DPDK_BUILD/pktgen $DPDK_PARAMS -- $PKTGEN_PARAMS"
echo "Launching pktgen...CMD=$CMD"
$CMD

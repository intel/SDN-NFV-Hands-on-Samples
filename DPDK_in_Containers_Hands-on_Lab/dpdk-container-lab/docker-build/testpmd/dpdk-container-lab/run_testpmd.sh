#!/bin/bash

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

if [ "$DPDK_DIR" == "" ]; then
	echo "Sorry, DPDK_DIR env var has not been set to root of DPDK src tree"
	exit 1
fi

#-i -- interactive mode
#--burst=64: we are going to fetch 64 packets at at time
#--txd=2048/--rxd=2048: we want 2048 descriptors in the rx and tx rings
#--forward-mode=io: forward all packets received
#--auto-start: start forwarding packets immediately on launch
#--disable-hw-vlan: disable hardware VLAN
#--coremask=0xC0: lock tespmd to run on cores 6-7 (0b1100 0000)
TESTPMD_PARAMS="--burst=64 -i --disable-hw-vlan --txd=2048 --rxd=2048 --forward-mode=io --auto-start --coremask=0xC0"

#-c 0xE0: DPDK can run on core 5-7: (0b1110 0000)
#--master-lcore 5: make the make the master testpmd thread run on core 5 (0b0010 0000)
#-n 1: we only have one memory bank in this VM
#--socket-mem 1024: use 1GB per socket  
#--file-prefix testpmd: "testpmd" will be appended to hugepage memory files used by this process
#--no-pci don't look for any PCI devices
#--vdev=net_virtio_user2,mac=00:00:00:00:00:02,path=/var/run/openvswitch/vhost-user2
#--vdev=net_virtio_user3,mac=00:00:00:00:00:03,path=/var/run/openvswitch/vhost-user3: use a virtual 
#	device using the net_virtio_user driver, MAC address 00:00:00:00:00:03, and the path to the 
#	unix socket is /var/run/openvswitch/vhost-user3
DPDK_PARAMS_VIRTIO="-c 0xE0 --master-lcore 5 -n 1 --socket-mem 1024 --file-prefix testpmd --no-pci --vdev=net_virtio_user2,mac=00:00:00:00:00:02,path=/var/run/openvswitch/vhost-user2 --vdev=net_virtio_user3,mac=00:00:00:00:00:03,path=/var/run/openvswitch/vhost-user3"

DPDK_PARAMS=$DPDK_PARAMS_VIRTIO

CMD="$DPDK_DIR/app/test-pmd/testpmd $DPDK_PARAMS -- $TESTPMD_PARAMS"
echo "Running $CMD"
$CMD

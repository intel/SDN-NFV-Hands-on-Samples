#!/bin/bash

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

if [ "$RTE_SDK" == "" ]; then
	echo "Sorry, RTE_SDK has not been defined."
	exit 1
fi

if [ "$RTE_TARGET" == "" ]; then
	echo "Sorry, RTE_TARGET has not been defined."
	exit 1
fi

if [ "$DPDK_BUILD" == "" ]; then
	echo "Sorry, DPDK_BUILD has not been defined."
	exit 1
fi

if [ "$DPDK_DIR" == "" ]; then
	echo "Sorry, DPDK_DIR has not been defined."
	exit 1
fi

if [ "$OVS_DIR" == "" ]; then
	echo "Sorry, OVS_DIR has not been defined."
	exit 1
fi

echo "Cleaning up any allocated resources"
./cleanup.sh

echo "Re-allocating hugepages"
echo 2048  > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

echo "Creating openvswitch directories"
mkdir -p /usr/local/etc/openvswitch
mkdir -p /usr/local/var/run/openvswitch

echo "Mounting the hugepage tlfs"
mount -t hugetlbfs none /mnt/huge

echo "Show the fs table:"
mount | grep -i huge

echo "Inserting the user-space IO driver into the kernel"
modprobe uio
insmod $DPDK_DIR/$DPDK_BUILD/kmod/igb_uio.ko

echo "Show free/used hugepage info"
cat /proc/meminfo | grep -i huge


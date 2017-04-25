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

echo "Terminating Open vSwitch processes"
pkill -9 ovs

echo "Removing directories used by Open vSwitch"
rm -rf /usr/local/var/run/openvswitch
rm -rf /usr/local/etc/openvswitch/
rm -f /tmp/conf.db

echo "Unmounting hugepages"
umount nodev /mnt/huge

echo "Deleting huge page memory files..."
rm -rf /dev/hugepages/*

echo "Show the fs table's hugepage mounts"
mount | grep -i huge


echo "Show free/used hugepage info"
cat /proc/meminfo | grep -i huge

echo "Removing from the kernel any DPDK drivers that may still be in use"
#rmmod i40e
#rmmod ixgbe
rmmod igb_uio
rmmod cuse
rmmod fuse
rmmod openvswitch
rmmod uio
rmmod eventfd_link
rmmod ioeventfd
rm -rf /dev/vhost-net

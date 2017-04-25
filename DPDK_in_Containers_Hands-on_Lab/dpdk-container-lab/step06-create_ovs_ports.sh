#!/bin/bash

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

if [ "$OVS_DIR" == "" ]; then
	echo "Sorry, OVS_DIR has not been defined."
	exit 1
fi

cd $OVS_DIR
echo "Before creating the DPDK ports, tell OVS to use Core 2 for the DPDK PMD"
./utilities/ovs-vsctl set Open_vSwitch . other_config:pmd-cpu-mask=0x4 #1core

echo "Done"

echo "Create bridge br0 and vhost ports"
./utilities/ovs-vsctl add-br br0 -- set bridge br0 datapath_type=netdev
./utilities/ovs-vsctl add-port br0 vhost-user1 -- set Interface vhost-user1 type=dpdkvhostuser
./utilities/ovs-vsctl add-port br0 vhost-user2 -- set Interface vhost-user2 type=dpdkvhostuser
./utilities/ovs-vsctl add-port br0 vhost-user3 -- set Interface vhost-user3 type=dpdkvhostuser
./utilities/ovs-vsctl add-port br0 vhost-user4 -- set Interface vhost-user4 type=dpdkvhostuser

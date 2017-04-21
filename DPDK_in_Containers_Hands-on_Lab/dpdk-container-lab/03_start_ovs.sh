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

echo "Initializing the new OVS database"
cd $OVS_DIR
./ovsdb/ovsdb-tool create /usr/local/etc/openvswitch/conf.db ./vswitchd/vswitch.ovsschema

echo "Starting the OVS database server"
./ovsdb/ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
                 --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
                 --pidfile --detach

echo "Initializing the OVS database"
./utilities/ovs-vsctl --no-wait init


echo "Telling the OVS controller to start OVS with DPDK using 1GB and run the ovswitchd daemon on logical core 1"
./utilities/ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true \
 other_config:dpdk-lcore-mask=0x2 other_config:dpdk-socket-mem="1024"

echo "Starting the OVS daemon..."
./vswitchd/ovs-vswitchd unix:/usr/local/var/run/openvswitch/db.sock --pidfile --detach

sleep 2

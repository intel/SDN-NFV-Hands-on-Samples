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

echo "Show br0 info:"
./utilities/ovs-vsctl show

echo "Showing vhost-user sockets in /usr/local/var/run/openvswitch"
ls -la /usr/local/var/run/openvswitch | grep vhost-user

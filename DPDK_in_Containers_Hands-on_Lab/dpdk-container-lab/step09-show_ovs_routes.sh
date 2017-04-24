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
alias echo='echo'

echo "Showing the current flow configuration:"
./utilities/ovs-ofctl dump-flows br0

echo "Showing OpenFlow to Open vSwitch port mapping:"
./utilities/ovs-ofctl show br0
sleep 1

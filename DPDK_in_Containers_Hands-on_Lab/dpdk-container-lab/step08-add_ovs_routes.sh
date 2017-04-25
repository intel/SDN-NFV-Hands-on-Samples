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

echo "**********Clearing current flows" 
./utilities/ovs-ofctl del-flows br0 
 
echo "(Add bi-directional flow vhost-user2 and vhost-user3)"
./utilities/ovs-ofctl add-flow br0 in_port=2,dl_type=0x800,idle_timeout=0,action=output:3
./utilities/ovs-ofctl add-flow br0 in_port=3,dl_type=0x800,idle_timeout=0,action=output:2

echo "(Add bi-directional flow between vhost-user1 and vhost-user4)"
./utilities/ovs-ofctl add-flow br0 in_port=1,dl_type=0x800,idle_timeout=0,action=output:4
./utilities/ovs-ofctl add-flow br0 in_port=4,dl_type=0x800,idle_timeout=0,action=output:1

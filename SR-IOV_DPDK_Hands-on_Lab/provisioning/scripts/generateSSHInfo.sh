#!/bin/bash -

# Copyright (c) 2016 Intel Corporation

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Author: Clayne B. Robison <clayne dot b dot robison at intel dot com>

#This script generates the SSH information that gets rolled into the ssh_config file on the jump server. This script was derived from the cloneImages.sh script, and technically is not necessary.

if [ "$(id -u)" != "0" ]; then
	echo "Sorry, you are not root."
	exit 1
fi

HOSTS_PER_COMP_NODE=4
COMP_NODE_ID=$(hostname | cut -c 6-7)
echo "comp node id = $COMP_NODE_ID"
PROVISIONING_DIR=/home/sdnnfv-admin/provisioning-slave
CLONE_SOURCE_DOMAIN_XML=$PROVISIONING_DIR/HostVM-Master.xml
SSH_CONFIG_FILE=$PROVISIONING_DIR/ssh_config
NETWORK="172.16."
IP_ADDR_PREFIX=${NETWORK}"140."
HOSTVM_HOSTNAME_PREFIX="HostVM-"
TENANTVM_HOSTNAME_PREFIX="TenantVM-"
VNFVM_HOSTNAME_PREFIX="VNF-VM-"

#For every HostVM on this compute node
currentHost=0
while [ $currentHost -lt $HOSTS_PER_COMP_NODE ] ; do
#generate the last quad of the static IP address
	last_quad=$(( 10#$COMP_NODE_ID * $HOSTS_PER_COMP_NODE + $currentHost))
#generate the last two digits of the VM ID
	host_id=$((( 10#$COMP_NODE_ID - 1 ) * $HOSTS_PER_COMP_NODE + $currentHost ))
	currentIPAddr=${IP_ADDR_PREFIX}$last_quad
#If the VM ID only has one digit, then prefix it with a 0
	if [ $host_id -lt 10 ] ; then
		printf -v host_id "%02d" $host_id
    fi
	echo "current Host ID                   = $host_id"
	currentHostVMHostname=${HOSTVM_HOSTNAME_PREFIX}$host_id
	currentTenantVMHostname=${TENANTVM_HOSTNAME_PREFIX}$host_id
	currentVNFVMHostname=${VNFVM_HOSTNAME_PREFIX}$host_id

	echo "current IP Address		= $currentIPAddr"
	echo "current HostVM hostname		= $currentHostVMHostname"
	echo "current TenantVM hostname	= $currentTenantVMHostname"
	echo "current VNFVM hostname		= $currentVNFVMHostname"

	#write the new host, VNF, and Tenant VM info to the ssh_config file so users can hit from the jump server
	echo "writing ssh info to $SSH_CONFIG_FILE"
	cat >> $SSH_CONFIG_FILE << EOF

Host $currentHostVMHostname
        User    user
        HostName        $currentIPAddr
	
Host $currentVNFVMHostname
        User    user
        ProxyCommand ssh -q $currentHostVMHostname nc -q0 192.168.120.10 22
	
Host $currentTenantVMHostname
        User    user
        ProxyCommand ssh -q $currentHostVMHostname nc -q0 192.168.120.11 22
EOF

	((currentHost++))
done

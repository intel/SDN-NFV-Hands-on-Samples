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

#The cloneImages.sh script does the heavy lifting of creating the HostVM clones from HostVM-Master. It is intended to be run on the compute nodes. It does the following:
#	1. Calculates the last quad of the static IP Address of the new HostVM from the last two digits of the compute node hostname; 
#	2. Calculates the last two digits of the HostVM and nested Tenant and VNF VMs from thte last two digits of the compute node's hostname;
#	3. Uses virt-clone to create a complete clone of HostVM-Master
#	4. Uses virt-sysprep to 
#		a. delete all user accounts except user and root;
#		b. reset dhcp-client-state
#		c. create a new machine-id
#		d. reset ssh-hostkeys
#		e. delete the ~/.ssh directory
#		f. set the new hostname, and
#		g. dpkg-reconfigure openssh-server to get the ssh server keys setup correctly
#	5. Uses guestfish to edit the newly create image file and
#		a. add static IP address info into /etc/network/interfaces.d/ens3
#		b. add the new hostname info to /etc/hosts
#	6. Create an entry in the ssh_config file for the new Host, VNF, and Tenant VMs
#The script has the following pre-conditions:
#	1. The HostVM-Master.xml domain definition file is in $PROVISIONING_DIR
#	2. The HostVM-Master.qcow2 image file is in $VM_IMAGE_PATH
#	3. The last two digits of the compute node's hostname are numeric
#	4. virt-clone, virt-sysprep, and guestfish are installed on the compute node

if [ "$(id -u)" != "0" ]; then
	echo "Sorry, you are not root."
	exit 1
fi

#set up all of the variables and constants
HOSTS_PER_COMP_NODE=4
COMP_NODE_ID=$(hostname | cut -c 6-7)
echo "comp node id = $COMP_NODE_ID"
PROVISIONING_DIR=/home/sdnnfv-admin/provisioning-slave
CLONE_SOURCE_DOMAIN_XML=$PROVISIONING_DIR/HostVM-Master.xml
NETWORK="172.16."
IP_ADDR_PREFIX=${NETWORK}"140."
SSH_CONFIG_FILE=$PROVISIONING_DIR/ssh_config
HOSTVM_HOSTNAME_PREFIX="HostVM-"
TENANTVM_HOSTNAME_PREFIX="TenantVM-"
VNFVM_HOSTNAME_PREFIX="VNF-VM-"

VM_IMAGE_PATH=/var/lib/libvirt/images

#for each of the HostVMs on this compute node
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
	echo "current Host ID 			= $host_id"
#set the variables for this HostVM
	currentHostVMHostname=${HOSTVM_HOSTNAME_PREFIX}$host_id
	currentHostVMImageFile=$VM_IMAGE_PATH/${currentHostVMHostname}.qcow2
	currentTenantVMHostname=${TENANTVM_HOSTNAME_PREFIX}$host_id
	currentVNFVMHostname=${VNFVM_HOSTNAME_PREFIX}$host_id

	echo "current IP Address		= $currentIPAddr"
	echo "current HostVM hostname		= $currentHostVMHostname"
	echo "current TenantVM hostname	= $currentTenantVMHostname"
	echo "current VNFVM hostname		= $currentVNFVMHostname"

#run virt-clone to fully clone the Master image
	echo "Using XML $CLONE_SOURCE_DOMAIN_XML to create $currentHostVMHostname using $currentIPAddr on $currentHostVMImageFile"
	virt-clone --original-xml=$CLONE_SOURCE_DOMAIN_XML --name $currentHostVMHostname --file $currentHostVMImageFile

#run virt-sysprep to clean up the new image
	virt-sysprep  --operations user-account,dhcp-client-state,machine-id,ssh-hostkeys,ssh-userdir,customize --hostname $currentHostVMHostname -a $currentHostVMImageFile --run-command 'dpkg-reconfigure openssh-server' --keep-user-accounts user,root

#use guestfish to edit the image with the new static IP address for ens3, and the new hostname in /etc/hosts
	#remove /etc/network/interfaces.d/ens3
	#write the contents of the file with the new IP address
	guestfish -a "$currentHostVMImageFile" -i <<EOF
		rm /etc/network/interfaces.d/ens3
		write_append /etc/network/interfaces.d/ens3 "auto ens3\n"
		write_append /etc/network/interfaces.d/ens3 "iface ens3 inet static\n"
        	write_append /etc/network/interfaces.d/ens3 "  address $currentIPAddr\n"
        	write_append /etc/network/interfaces.d/ens3 "  netmask 255.255.0.0\n"
        	write_append /etc/network/interfaces.d/ens3 "  network ${NETWORK}0.0\n"
        	write_append /etc/network/interfaces.d/ens3 "  broadcast ${NETWORK}255.255\n"
        	write_append /etc/network/interfaces.d/ens3 "  gateway ${NETWORK}255.1\n"
        	write_append /etc/network/interfaces.d/ens3 "  dns-nameservers ${NETWORK}140.1"

		rm /etc/hosts
		write_append /etc/hosts "127.0.0.1\tlocalhost\n"
		write_append /etc/hosts "$currentIPAddr\t$currentHostVMHostname\n"
		write_append /etc/hosts "\n"
		write_append /etc/hosts "ff02::1\tip6-allnodes\n"
        	write_append /etc/hosts "ff02::2\tip6-allrouters"
EOF

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

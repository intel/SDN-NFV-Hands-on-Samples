#!/usr/bin/python

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

##################################
#
# This module edits the libvirt XML definition file and inserts sr-iov nics on the compute node into the specified VMs. It expects there to be 4 SR-IOV NIC ports per compute node (e.g. one Intel(R) XL710 Ethernet Interface) with 2 guest VMs each getting 2 SR-IOV NIC ports. It also expects those SR-IOV NICS to already be defined as separate libvirt networks. (In reality, a single libvirt network can expose a pool of SR-IOV virtual functions, that number limited by the NIC hardware/driver. However, in this lab, each libvirt network exposed only a single virtual function. See https://wiki.libvirt.org/page/Networking#Assignment_from_a_pool_of_SRIOV_VFs_in_a_libvirt_.3Cnetwork.3E_definition for more information on how to define a libvirt network that exposes a pool of SR-IOV virtual functions.) 

#If the SR-IOV NICs have not been defined as libvirt networks, and if those libvirt networks are not active, the edited VMs will fail to start.

#This module also expects there to already be two existing network interfaces in the VM XML domain definition file.

# This script is intended to be run on the compute nodes that are exposing the SR-IOV virtual functions.
 
from __future__ import print_function
import sys
from xml.etree.ElementTree import ElementTree, Element, tostring, fromstring 

#VMManager is defined in this project and handles most VM Management tasks
from VMManager import VMManager

SR_IOV_GUESTS_PER_NODE=2
SR_IOV_NICS_PER_GUEST=2
NUM_EXISTING_INTERFACES=2 
PATH='/home/sdnnfv-admin/provisioning-slave/temp_xml'

#create an array of XML tags that define the SR-IOV NICs and their source libvirt networks
#This script expects there to be libvirt networks defined that have the following names
#that point to the physical function associated with the SR-IOV port:
#'sr-iov-port0','sr-iov-port1','sr-iov-port2','sr-iov-port3'

#See files/sr-iov-port0.xml, files/sr-iov-port1.xml, files/sr-iov-port2.xml, files/sr-iov-port3.xml and compute_node/02_load_vfs_into_libvirt.sh
sr_iov_networks = ['sr-iov-port0','sr-iov-port1','sr-iov-port2','sr-iov-port3']
sr_iov_nics = [[ 0 for x in range(SR_IOV_GUESTS_PER_NODE)] for y in range(SR_IOV_NICS_PER_GUEST)]
sr_iov_nics[0][0] = fromstring("<interface type='network'>	<source network='" + sr_iov_networks[0] + "'/></interface>")
sr_iov_nics[0][1] = fromstring("<interface type='network'>	<source network='" + sr_iov_networks[1] + "'/></interface>")
sr_iov_nics[1][0] = fromstring("<interface type='network'>	<source network='" + sr_iov_networks[2] + "'/></interface>")
sr_iov_nics[1][1] = fromstring("<interface type='network'>	<source network='" + sr_iov_networks[3] + "'/></interface>")

#Get the names of the VMs running on this host.
#ASSUMPTION: the SR-IOV nics are only being used by VMs whose names end with an even number, e.g. HostVM-52 or HostVM-08
host_vm_names = VMManager.get_domain_names(VMManager.VM_MASK_EVEN)

#if there are more or less than the expected number of SR-IOV guests, error and quit
if len(host_vm_names) != SR_IOV_GUESTS_PER_NODE:
	print("Unexpected number of SR-IOV hosts in this node: " + len(host_vm_names) + "  Exiting." , file=sys.stderr)
	exit(1)

#sort the SR-IOV VMs in numerial order
host_vm_names.sort()

for i in range(0, SR_IOV_GUESTS_PER_NODE):
	print("Adding SR-IOV VF NICS to  " + host_vm_names[i])
	#Shutdown VMs; might take a while
	VMManager.shutdown_domain(host_vm_names[i])

#Get the XML Dom tree for this VM
	domain = VMManager.domain_from_name(host_vm_names[i])

#dump the xml so we can save and edit
	domain_xml = domain.XMLDesc()

#make a copy of the xml so that we don't lose it on the undefine
	new_domain_root_elem = fromstring(domain_xml)
	with open(PATH + "/" + host_vm_names[i] + ".xml.bak", 'w') as f:
		f.write(domain_xml)

#insert the nics into the xml; this assumes that there are two other 
#interfaces on the VM, currently at positions 10 and 11
	devices = new_domain_root_elem.find('devices')
	interfaces = devices.findall('interface')
	if len(interfaces) == NUM_EXISTING_INTERFACES:
		devices.insert(12, sr_iov_nics[i][0])
		devices.insert(13, sr_iov_nics[i][1])
#undefine the old vm
		VMManager.undefine_domain(host_vm_names[i])
#define the machine using the new xml
		new_domain_xml = tostring(new_domain_root_elem)
		domain = VMManager.define_domain(new_domain_xml)

print("Done.")

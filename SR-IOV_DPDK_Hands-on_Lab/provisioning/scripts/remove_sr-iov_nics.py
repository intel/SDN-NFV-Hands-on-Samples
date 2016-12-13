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
# This module removes the sr-iov nics from specified VMs on the compute node. 
# It expects there to be 2 guests per compute node that use the SR-IOV NICS, that those guests end with even numbers, and that each guest has been using 2 SR-IOV NICS.
# Note that when the XML snippets to define the SR-IOV NICS are inserted into the domain XML definition, the XML tag looks like this, where 'sr-iov-port0' refers to an active libvirt network that has previously been defined to point at the NIC physical function that is hosting the virtual function:
# 	<interface type='network'>
#		<source network='sr-iov-port0'/>
#	</interface>
#See files/sr-iov-port0.xml, files/sr-iov-port1.xml, files/sr-iov-port2.xml, files/sr-iov-port3.xml and compute_node/02_load_vfs_into_libvirt.sh, and https://wiki.libvirt.org/page/Networking#Assignment_from_a_pool_of_SRIOV_VFs_in_a_libvirt_.3Cnetwork.3E_definition

# However, once the domain XML has been validated by libvirt during the create or define processes, libvirt allocates an SR-IOV NIC from the libivrt SR-IOV network pool and modifies the SR-IOV NIC XML snippet to point to the host machine's PCI address of the virtual function. The new XML snippet begins like this and thereafter refers to the source SR-IOV virtual function PCI address rather than the name of the libvirt network:
#	<interface type='hostdev'>

#This module does not restart the domains after editing them.

from __future__ import print_function
import sys
from xml.etree.ElementTree import ElementTree, Element, tostring, fromstring

#The VMManager module is defined as a part of this project
from VMManager import VMManager

SR_IOV_GUESTS_PER_NODE=2
SR_IOV_NICS_PER_GUEST=2
PATH='/home/sdnnfv-admin/provisioning-slave/temp_xml'

#hard coded XML tags and attributes
HOSTDEV_XML='hostdev'
SOURCE_XML='source'
NETWORK_XML='network'
SR_IOV_XML='sr-iov-'
TYPE_XML='type'
DEVICES_XML='devices'
INTERFACE_XML='interface'

#Get the names of the VMs running on this host. 
#ASSUMPTION: the SR-IOV nics are only being used by VMs whose names end with an even number, e.g. HostVM-52 or HostVM-08
host_vm_names = VMManager.get_domain_names(VMManager.VM_MASK_EVEN)

#if there are more or less than the expected number of SR-IOV guests, error and quit
if len(host_vm_names) != SR_IOV_GUESTS_PER_NODE:
	print("Unexpected number of SR-IOV hosts in this node: " + str(len(host_vm_names)) + ". VMs: " + str(host_vm_names)+ "  Exiting." , file=sys.stderr)
	exit(1)

#sort the SR-IOV VMs in numerical order
host_vm_names.sort()

for i in range(0, SR_IOV_GUESTS_PER_NODE):
	print("Removing SR-IOV VF NICS from  " + host_vm_names[i])
	#Shutdown VM; this might take a while
	VMManager.shutdown_domain(host_vm_names[i])

#Get the XML DOM tree for this VM
	domain = VMManager.domain_from_name(host_vm_names[i])

#dump the xml
	domain_xml = domain.XMLDesc()

#make a copy of the xml so that we don't lose it when we undefine it
	new_domain_root_elem = fromstring(domain_xml)
	with open('/home/sdnnfv-admin/provisioning-slave/' + host_vm_names[i] + ".xml.bak", 'w') as f:
		f.write(domain_xml)

#undefine the old vm
	VMManager.undefine_domain(host_vm_names[i])

#remove the nics from the xml; <interface> elements are children to the <devices> tag
	devices = new_domain_root_elem.find(DEVICES_XML)
	nics = devices.findall(INTERFACE_XML)
	for nic in nics: 
#if the type attribute of the interface tag is 'hostdev' then we know it is either
#a Physical Function PCI passthrough or an SR-IOV VF passthrough.
#Either way, remove it from the tree
		nic_type_str = nic.get(TYPE_XML)
		nic_source = nic.find(SOURCE_XML)
		if nic_type_str == None:
			print("Unable to find interface type information!! Continuing...")
#pattern <interface type='hostdev'>
		elif nic_type_str.find(HOSTDEV_XML) == 0:
			devices.remove(nic)
#it's also possible that the machine has never booted with the SR-IOV
#NICS. If that is the case, then libvirt hasn't modified the original
#xml tags, so look for them, and remove those nics as well.
#pattern 
#	<interface>
#		<source network="sr-iov-*"
		elif nic_source != None:
			nic_source_network_str = nic_source.get(NETWORK_XML)
			if nic_source_network_str != None and nic_source_network_str.find(SR_IOV_XML) == 0: 
				devices.remove(nic)
#define the machine using the new xml
	new_domain_xml = tostring(new_domain_root_elem)
	domain = VMManager.define_domain(new_domain_xml)

print("Done.")

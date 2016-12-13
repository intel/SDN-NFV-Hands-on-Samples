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
# This module changes the CPU topology of the HostVM guests to 1 socket with 8 cores and no hyper-threading.
# On each compute node, it shuts down the HostVM guests, saves the XML definition of each guest, undefines it, modifies the CPU XML tag, and then redefines the domain using the modified XML. The modified CPU tag looks like this:
#<cpu mode='host-passthrough'>
# <topology sockets='1' cores='8' threads='1'/>
#</cpu>
from __future__ import print_function
import sys
from xml.etree.ElementTree import ElementTree, Element, tostring, fromstring 

#VMManager is defined in this project
from VMManager import VMManager
SOCKETS='1'
CORES='8'
THREADS='1'
BACKUP_PATH='/home/sdnnfv-admin/provisioning-slave/'
CPU_XML="cpu"
TOPOLOGY_XML='topology'
#create the CPU topology XML snippet
# <topology sockets='1' cores='8' threads='1'/>
topology_xml = fromstring("<topology sockets='" + SOCKETS + "' cores='" + CORES + "' threads='" + THREADS + "'/>")
#Get the names of the VMs running on this host.
host_vm_names = VMManager.get_domain_names(VMManager.VM_MASK_ALL)

for i in range(0, len(host_vm_names)):
	print("Modifying CPU topology for " + host_vm_names[i])
	#Shutdown VMs; might take a while
	VMManager.shutdown_domain(host_vm_names[i])

#Get the XML Dom tree for this VM
	domain = VMManager.domain_from_name(host_vm_names[i])

#dump the xml
	domain_xml = domain.XMLDesc()

#make a copy of the xml so that we don't lose it on the undefine
	new_domain_root_elem = fromstring(domain_xml)
	with open(BACKUP_PATH + host_vm_names[i] + ".xml.bak", 'w') as f:
		f.write(domain_xml)

#insert the topology snippet as a child to thet cpu elem, making sure that it doesn't already exist
#and then redefine the machine if it was changed
	cpu_elem = new_domain_root_elem.find(CPU_XML)
	if cpu_elem.find(TOPOLOGY_XML) == None:
		print("Adding the topology node.")
		cpu_elem.append(topology_xml)
#undefine the old vm
		VMManager.undefine_domain(host_vm_names[i])
#define the machine using the new xml
		new_domain_xml = tostring(new_domain_root_elem)
		domain = VMManager.define_domain(new_domain_xml)

print("Done.")

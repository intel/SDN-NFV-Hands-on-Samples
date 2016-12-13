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

from __future__ import print_function
import libvirt
import sys
import time

class VMManager:
	'This class contains all of the functions that we use to progammatically manage the VMs on each compute node. Because there is no state saved, all of the methods and attributes on this class are class scope and there is no __init()__ method.'
	#from https://docs.rs/libvirt-sys/1.2.18/libvirt_sys/constant.VIR_CONNECT_LIST_DOMAINS_SHUTOFF.html
	VIR_CONNECT_LIST_DOMAINS_ACTIVE=1
	VIR_CONNECT_LIST_DOMAINS_SHUTOFF=64
	#Masks to help refine searches
	VM_MASK_ALL=0
	VM_MASK_ODD=1
	VM_MASK_EVEN=2
	#Modify this value if you need more  or less time to start or shutdown VMs
	SLEEP_TIME=5

	@classmethod
	def get_domains(cls):
		'This function returns a list of all domains that are defined on the system, regardless of state. The function always returns a list; if there is an error, the list will be empty.'
		retVal = []
		conn = None
		try:
			conn = libvirt.open('qemu:///system')
			retVal = conn.listAllDomains(0)
		except libvirt.libvirtError as e:
			print("Got a libVirtError trying to get Domain Names " + str(e))
		else :
			if conn == None:
				print('Failed to open connection to qemu:///system', file=sys.stderr)
			else:
				conn.close()
		return retVal


	@classmethod
	def get_domain_names(cls, vm_mask=VM_MASK_ALL):
		'This class method returns a list of the names of all the libvirt domains on the compute node. It always returns a list, even though it may be empty. '
		domains = None
		retVal = []
		conn = None
		try:
			#open a connection to libvirt and get the domains
			conn = libvirt.open('qemu:///system')
			#the get_domains() method also opens a connection, but we need one to get the domain names.
			domains = cls.get_domains()
			for domain in domains:
				#check to see if we need to apply a filter
				try: # check for valueErrors
					#this returns just the final two characters of the domain name
					#e.g. HostVM-02 returns just '02'
					host_id = int( cls.id_from_name (domain.name()))
					if vm_mask == cls.VM_MASK_ALL:#They want all the names
						retVal.append(domain.name())
					elif vm_mask == cls.VM_MASK_ODD and host_id % 2 == 1 : 
						#They only want the domain names that end with ODD numbers 
						retVal.append(domain.name())
					elif vm_mask == cls.VM_MASK_EVEN and host_id % 2 == 0: 
						#They only want domain names that end with Even numbers.
						retVal.append(domain.name())
				except ValueError as e: #We had an error when we tried to parse something other than a number
					print("'" + cls.id_from_name(domain.name()) + "' is not numeric. Continuing.")
					#add it anyway if they are looking for all hosts
					if vm_mask == cls.VM_MASK_ALL:
						retVal.append(domain.name())
		except libvirt.libvirtError as e:
			print("Got a libVirtError trying to get Domain Names " + str(e))
		else :
			if conn == None:
				print('Failed to open connection to qemu:///system', file=sys.stderr)
			else:
				conn.close()
		return retVal

	@classmethod
	def id_from_name(cls, domain_name):
		'THis function assumes that the domain_name parameter is of the form "HostVM-XX" where XX is the ID that is returned. If the ID < 10, the return value has a 0 prefix, e.g. "02". This function does no value checking to see if the ID is numeric. If domain_name is not valid, returns empty string.'
		if domain_name == None or len(domain_name) == 0:
			return ""
		else:
			return domain_name.rsplit('-')[1]

	@classmethod
	def domain_from_name(cls, domain_name):
		'This function returns the domain object associated with domain_name to thte caller. If a domain with the specified domain name is not found, the function returns None.'
		retVal = None
		try:
			conn = libvirt.open('qemu:///system')
			domains = cls.get_domains()
			for domain in domains:
				if domain.name() == domain_name:
					retVal = domain
					break
		except libvirt.libvirtError as e:
			print("Got an error trying to get a handle to domain with the name: " + domain_name + ". " + str(e), file=sys.stderr)
		else:
			if conn != None:
				conn.close()
		return retVal

	@classmethod
	def undefine_domain(cls, domain_name):
		'This function will undefine a single domain, whose name is passed as parameter. If domain_name is "", or if the domain_name is None, then this function does nothing.'
		domain=None
		conn=None
		if domain_name == None or domain_name == "":
			return 
		try:
			conn = libvirt.open('qemu:///system')
			domain = conn.lookupByName(domain_name)
			if domain != None:
				if ( domain.isActive() ):
					domain.shutdown()
					time.sleep(cls.SLEEP_TIME)
				domain.undefine()
		except libvirt.libvirtError as e:
			print("Got a libVirtError trying to undefine " + domain_name() + ": " + str(e), file=sys.stderr)
			print("Continuing...", file=sys.stderr)
		else:
			conn.close()
		return


	@classmethod
	def define_domain(cls, domain_xml):
		'This function defines a domain using the supplied xml; it does not start it.'
		conn = None
		domain = None
		try:
			conn = libvirt.open('qemu:///system')
			domain = conn.defineXML(domain_xml)
		except libvirt.libvirtError as e:
			print("Got a libVirtError trying to define a domain using this XML: "  + domain_xml + ": " + str(e), file=sys.stderr)
		else:
			conn.close()
		return domain

	@classmethod
	def shutdown_domain(cls, domain_name):
		'This function will shutdown a single domain, whose name is passed as parameter. The function waits for SLEEP_TIME seconds before returning. If domain_name is "" or if it is None, then this function does nothing.'
		domain=None
		conn=None
		if domain_name == None or domain_name == "":
			return 
		try:
			conn = libvirt.open('qemu:///system')
			domain = conn.lookupByName(domain_name)
			if domain != None and domain.isActive():
				domain.shutdown()
		except libvirt.libvirtError as e:
			print("Got a libVirtError trying to stop " + domain.name() + ": " + str(e), file=sys.stderr)
			print("Continuing...", file=sys.stderr)
		else:
			time.sleep(cls.SLEEP_TIME)
			if conn != None:
				conn.close()
		return


	@classmethod
	def shutdown_domains(cls,  vm_mask=VM_MASK_ALL):
		'This function shuts down domains on the compute node, optionally shutting down only some of the domains, based on the input mask. By default, it shuts down all domains. If vm_mask is VM_MASK_ODD, only domains ending with odd numbers are shutdown; if vm_mask is VM_MASK_EVEN, only domains ending with even numbers are shutdown. '
		conn = libvirt.open('qemu:///system')
		domains = conn.listAllDomains(cls.VIR_CONNECT_LIST_DOMAINS_ACTIVE)
		while len(domains) != 0:
			for domain in domains:
				try:
					domain.shutdown()
				except libvirt.libvirtError as e:
					print("Got a libVirtError trying to shutdown " + domain.name() + ": " + str(e), file=sys.stderr)
					print("Continuing...", file=sys.stderr)
			time.sleep(cls.SLEEP_TIME)
			conn.close()
			conn = libvirt.open('qemu:///system')
			domains = conn.listAllDomains(cls.VIR_CONNECT_LIST_DOMAINS_ACTIVE)
		conn.close()
		return

	@classmethod
	def start_domain(cls, domain_name):
		'This function will start a single domain, whose name is passed as parameter. The function waits for SLEEP_TIME seconds before returning to give the domain time to start. If domain_name is "", or if the domain_name is None, or if the domain is already running, then this function does nothing.'
		domain=None
		conn=None
		if domain_name == None or domain_name == "":
			return 
		try:
			conn = libvirt.open('qemu:///system')
			domain = conn.lookupByName(domain_name)
			if domain != None and domain.state != libvirt.VIR_DOMAIN_RUNNING:
				domain.create()
		except libvirt.libvirtError as e:
			print("Got a libVirtError trying to start " + domain.name() + ": " + str(e), file=sys.stderr)
			print("Continuing...", file=sys.stderr)
		else:
			time.sleep(cls.SLEEP_TIME)
			if conn != None:
				conn.close()
		return

	@classmethod
	def start_domains(cls, vm_mask=VM_MASK_ALL):
		'This function starts domains on the compute node, optionally starting only some of the domains, based on the input mask. By default, it starts all domains. If vm_mask is VM_MASK_ODD, only domains ending with odd numbers are started; if vm_mask is VM_MASK_EVEN, only domains ending with even numbers are started. This function waits for SLEEP_TIME seconds before returning in order to give the domains time to start.'
		conn = libvirt.open('qemu:///system')
		domains = conn.listAllDomains(cls.VIR_CONNECT_LIST_DOMAINS_SHUTOFF)
		while len(domains) != 0:
			for domain in domains:
				try:
					domain.create()
				except libvirt.libvirtError as e:
					print("Got a libVirtError trying to start " + domain.name() + ": " + str(e), file=sys.stderr)
					print("Continuing...", file=sys.stderr)
			time.sleep(cls.SLEEP_TIME)
			conn.close()
			conn = libvirt.open('qemu:///system')
			domains = conn.listAllDomains(cls.VIR_CONNECT_LIST_DOMAINS_SHUTOFF)
		conn.close()
		return



#!/bin/bash

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

#This script creates libvirt networks on the SR-IOV functions that have been 
#defined in the previous step. It assumes that the XML files sr-iov-port0-3.xml
#are already present at $SR_IOV_NET_FILE_PATH

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

#Change this to be the location of the XML files that define the SR-IOV NIC-based networks

SR_IOV_NET_FILE_PATH="/home/sdnnfv-admin/provisioning-slave/sr-iov-networks"

#This script loads the existing virtual functions into the system libvirt network
echo "Defining network pools of Virtual Functions..."
virsh net-define $SR_IOV_NET_FILE_PATH/sr-iov-port0.xml
virsh net-define $SR_IOV_NET_FILE_PATH/sr-iov-port1.xml
virsh net-define $SR_IOV_NET_FILE_PATH/sr-iov-port2.xml
virsh net-define $SR_IOV_NET_FILE_PATH/sr-iov-port3.xml

#Start the SR-IOV based networks, otherwise libvirt will whine when we start the VMs
#The names of these networks are the names that are found in the XML files, and have nothing to do with the names of the XML files that defined them.
echo "Starting virtual function networks..."
virsh net-start sr-iov-port0
virsh net-start sr-iov-port1
virsh net-start sr-iov-port2
virsh net-start sr-iov-port3

#display the status of the KVM networks on this node
virsh net-list --all


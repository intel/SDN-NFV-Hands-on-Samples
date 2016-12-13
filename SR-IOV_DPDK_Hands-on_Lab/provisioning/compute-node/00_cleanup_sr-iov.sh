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

#This script shuts down the networks that are using SR-IOV and unloads the VFs from the compute node kernel.  It assumes that the 4 ports on the XL710 NIC have been assigned interfaces enp6s0f0-3 (PCI Bus 6, Slot 0, Function 0-3)

#make sure we are root
if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

#destroy the sr-iov networks if they are running
echo "Shutting down sr-iov networks..."
virsh net-destroy sr-iov-port0
virsh net-destroy sr-iov-port1
virsh net-destroy sr-iov-port2
virsh net-destroy sr-iov-port3

#undefine them
echo "Undefining sr-iov networks..."
virsh net-undefine sr-iov-port0
virsh net-undefine sr-iov-port1
virsh net-undefine sr-iov-port2
virsh net-undefine sr-iov-port3

virsh net-list --all

#This is how you do it on kernel versions 3.8 and above
echo "Removing Virtual Functions..."
echo 0 > /sys/class/net/enp6s0f0/device/sriov_numvfs
echo 0 > /sys/class/net/enp6s0f1/device/sriov_numvfs
echo 0 > /sys/class/net/enp6s0f2/device/sriov_numvfs
echo 0 > /sys/class/net/enp6s0f3/device/sriov_numvfs
lspci | grep -i "net"

#Deactivate the Physical NIC ports
echo "Deactivating NIC ports..."
ip l set dev enp6s0f0 down
ip l set dev enp6s0f1 down
ip l set dev enp6s0f2 down
ip l set dev enp6s0f3 down


#You might get errors from this if they aren't already loaded in the kernel. Ignore them.
echo "removing SR-IOV drivers from kernel..."
rmmod pci-stub
rmmod i40evf
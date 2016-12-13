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

#This script automates the host device (compute node) OS parts of creating the SR-IOV
#NICs. It creates one Virtual Function for each of the 4 ports on the XL710 NIC
#It assumes that the 4 ports have been assigned interfaces enp6s0f0-3 (PCI Bus 6, Slot 0, Function 0-3)

#make sure we are root
if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

echo "Inserting pci-stub module into kernel..."
modprobe pci_stub
lsmod | grep pci


#This will insert the i40evf module into the kernel
echo "Creating Virtual functions..."
echo 1 > /sys/class/net/enp6s0f0/device/sriov_numvfs
echo 1 > /sys/class/net/enp6s0f1/device/sriov_numvfs
echo 1 > /sys/class/net/enp6s0f2/device/sriov_numvfs
echo 1 > /sys/class/net/enp6s0f3/device/sriov_numvfs
lspci | grep net

#These MAC addresses appear to be ignored by libvirt. 
echo "assigning mac addresses to virtual functions"
ip l set dev enp6s0f0 vf 0 mac aa:bb:cc:dd:ee:00
ip l set dev enp6s0f1 vf 0 mac aa:bb:cc:dd:ee:01
ip l set dev enp6s0f2 vf 0 mac aa:bb:cc:dd:ee:02
ip l set dev enp6s0f3 vf 0 mac aa:bb:cc:dd:ee:03

#Activate the NIC ports otherwise libvirt whines when we create virtual networks on them
echo "Activating NIC ports..."
ip l set dev enp6s0f0 up
ip l set dev enp6s0f1 up
ip l set dev enp6s0f2 up
ip l set dev enp6s0f3 up

#Show the current state of the interfaces
ip l show dev enp6s0f0
ip l show dev enp6s0f1
ip l show dev enp6s0f2
ip l show dev enp6s0f3
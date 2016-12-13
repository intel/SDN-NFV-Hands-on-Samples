#!/bin/sh

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

#This script launches the TenantVM using the Fedora 23 image found at /home/usr/vm-images/Fed23_VNFVM.img. The image is launched with 4G of RAM on 4 1G Hugepages from the HostVM. It has 3 NICs, 2 of which use the DPDK-enabled vhostuser ports from Open vSwitch, and the remaining NIC is attached to a tuntap bridge interface and assigned the static IP address 192.168.120.10 by the OS upon boot. 

vm=/home/user/vm-images/Fed23_VNFVM.img
vm_name=VNFVM-61
vnc=3
n1=tap1
bra=virbr0
dn_scrp_a=/root/br-mgt-ifdown
mac1=00:00:14:42:04:28
system_ram=4096
dpdk_ram=4096

if [ ! -f $vm ];
then
    echo "VM $vm not found!"
else
    echo "VM $vm started! VNC: $vnc, net0: $n1, net1: $n2"
    tunctl -d $n1
    tunctl -t $n1
    brctl addif $bra $n1
    ifconfig $n1 0.0.0.0 up

        /home/user/qemu-2.6.0/x86_64-softmmu/qemu-system-x86_64 -m $system_ram -smp 3 -cpu host -hda $vm  -boot c -enable-kvm -name $vm_name \
-object memory-backend-file,id=mem,size=${dpdk_ram}M,mem-path=/dev/hugepages,share=on -numa node,memdev=mem -mem-prealloc -nographic \
-netdev tap,id=t0,ifname=$n1,script=no,downscript=no \
-device e1000,netdev=t0,id=nic0,mac=$mac1 \
-chardev socket,id=char1,path=/usr/local/var/run/openvswitch/vhost-user0 \
-netdev type=vhost-user,id=net1,chardev=char1,vhostforce -device virtio-net-pci,netdev=net1,mac=00:00:00:00:00:01,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,mrg_rxbuf=off \
-chardev socket,id=char2,path=/usr/local/var/run/openvswitch/vhost-user1 \
-netdev type=vhost-user,id=net2,chardev=char2,vhostforce -device virtio-net-pci,netdev=net2,mac=00:00:00:00:00:02,csum=off,gso=off,guest_tso4=off,guest_tso6=off,guest_ecn=off,mrg_rxbuf=off 

fi


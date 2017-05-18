# Copyright (c) 2017 Intel Corporation

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


#!/bin/bash

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

if [ "$DPDK_DIR" == "" ]; then
	echo "Sorry, DPDK_DIR env var has not been set to root of DPDK src tree"
	exit 1
fi

#-c 0xE0: DPDK can run on core 5-7: (0b1110 0000)
#--master-lcore 5: make the make the master testpmd thread run on core 5 (0b0010 0000)
#-n 1: we only have one memory bank in this VM
# --single-file -m 512: allocate hugepage memory in a single file. See http://dpdk.org/dev/patchwork/patch/10406/
#--file-prefix testpmd: "testpmd" will be appended to hugepage memory files used by this process
#--no-pci don't look for any PCI devices
#--vdev=net_virtio_user3,mac=00:00:00:00:00:03,path=/var/run/openvswitch/vhost-user3
#--vdev=net_virtio_user4,mac=00:00:00:00:00:04,path=/var/run/openvswitch/vhost-user4: use a virtual 
#	device using the net_virtio_user driver, MAC address 00:00:00:00:00:03, and the path to the 
#	unix socket is /var/run/openvswitch/vhost-user3
export DPDK_PARAMS="-c 0xE0 --master-lcore 5 -n 1 --single-file -m 512 --file-prefix testpmd --no-pci --vdev=net_virtio_user3,mac=00:00:00:00:00:03,path=/var/run/openvswitch/vhost-user3 --vdev=net_virtio_user4,mac=00:00:00:00:00:04,path=/var/run/openvswitch/vhost-user4"

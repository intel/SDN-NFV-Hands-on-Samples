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

if [ "$PKTGEN_DIR" == "" ]; then
	echo "Sorry, PKTGEN_DIR env var has not been set to root of PKTGEN src tree"
	exit 1
fi

if [ "$DPDK_DIR" == "" ]; then
	echo "Sorry, DPDK_DIR env var has not been set to root of DPDK src tree"
	exit 1
fi

if [ "$DPDK_BUILD" == "" ]; then
	echo "Sorry, DPDK_BUILD env var has not been set to DPDK target build env"
	exit 1
fi

#-c 0x19: DPDK can run on core 0,3-4: (0b0001 1001)
#--master-lcore 3: make the pktgen dpdk thread run on core 3 (0b1000)
#-n 1: we only have one memory bank in this VM
# --single-file -m 512: allocate hugepage memory in a single file. See http://dpdk.org/dev/patchwork/patch/10406/
#--file-prefix pktgen: "pktgen" will be appended to hugepage memory files used by this process
#--no-pci don't look for any PCI devices 
#--vdev 'virtio_user1,mac=00:00:00:00:00:01,path=/var/run/openvswitch/vhost-user1' 
#--vdev 'virtio_user2,mac=00:00:00:00:00:02,path=/var/run/openvswitch/vhost-user2'
export DPDK_PARAMS="-c 0x19 --master-lcore 3 -n 1 --single-file -m 512 --file-prefix pktgen --no-pci --vdev=net_virtio_user1,mac=00:00:00:00:00:01,path=/var/run/openvswitch/vhost-user1 --vdev=net_virtio_user2,mac=00:00:00:00:00:02,path=/var/run/openvswitch/vhost-user2"

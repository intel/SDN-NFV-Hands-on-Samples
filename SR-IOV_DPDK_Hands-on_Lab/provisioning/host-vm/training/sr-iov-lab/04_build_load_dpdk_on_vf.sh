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

#This script builds and configures DPDK on the target PCI/SR-IOV NIC ports. It
# 1. determines the MAC address for the testpmd and pktgen interfaces, 
# 2. builds DPDK, 
# 3. loads the DPDK igb_uio driver into the kernel, 
# 4. mounts the hugepage memory,
# 5. binds the SR-IOV NICS at PCI address 00:09.0 and 00:0a.0 to thte DPDK igb_uio driver, and then
# 6. displays the MAC addresses for the SR-IOV NICS that were just bound to DPDK so that information can be used in the following steps of the lab. 

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

if [ "$RTE_SDK" == "" ]; then
	echo "Sorry, RTE_SDK has not been defined."
	exit 1
fi

if [ "$RTE_TARGET" == "" ]; then
	echo "Sorry, RTE_TARGET has not been defined."
	exit 1
fi

export PCI_PORT_0="00:09.0"
export PCI_PORT_1="00:0a.0"
export TESTPMD_VF_IF="ens9"
export PKTGEN_VF_IF="ens10"
export TESTPMD_VF_MAC=$(ip l show ${TESTPMD_VF_IF} | grep ether | awk '{ print $2 }')
export PKTGEN_VF_MAC=$(ip l show ${PKTGEN_VF_IF} | grep ether | awk '{ print $2 }')
cd $RTE_SDK
make config O=$RTE_TARGET T=$RTE_TARGET
cd $RTE_TARGET
make -j10

modprobe uio
insmod $RTE_SDK/$RTE_TARGET/kmod/igb_uio.ko

mount -t hugetlbfs nodev /mnt/huge

cat /proc/meminfo

echo "Binding $PCI_PORT_0 to igb_uio"
python $RTE_SDK/tools/dpdk-devbind.py --bind=igb_uio $PCI_PORT_0
echo "Binding $PCI_PORT_1 to igb_uio"
python $RTE_SDK/tools/dpdk-devbind.py --bind=igb_uio $PCI_PORT_1
python $RTE_SDK/tools/dpdk-devbind.py --status

echo "******Keep these for the next step*****"
echo "PKTGEN_MAC=$PKTGEN_VF_MAC"
echo "TESTPMD_MAC=$TESTPMD_VF_MAC"
echo "******Keep these for the next step*****"


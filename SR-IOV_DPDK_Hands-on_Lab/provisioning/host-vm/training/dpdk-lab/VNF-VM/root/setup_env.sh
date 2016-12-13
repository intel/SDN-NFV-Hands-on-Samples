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

# Author: Irene Liew <irene dot liew at intel dot com>

#This script mounts the 1GB huge pages that were allocate at system boot. Thenit loads the igb_uio driver into the kernel and then binds PCI devices 00:04.0 and 00:05.0 (the DPDK-enabled vhostuser ports attached to Open vSwitch in the HostVM) to the igb_uio DPDK driver.
umount /mnt/huge
#umount /mnt/huge_2mb
mount -t hugetlbfs nodev /mnt/huge
#mount -t hugetlbfs nodev /mnt/huge_2mb -o pagesize=2mb
mount


DPDK_DIR=/root/dpdk-16.07

modprobe uio
insmod $DPDK_DIR/x86_64-native-linuxapp-gcc/kmod/igb_uio.ko

$DPDK_DIR/tools/dpdk-devbind.py -b igb_uio 00:04.0
$DPDK_DIR/tools/dpdk-devbind.py -b igb_uio 00:05.0

$DPDK_DIR/tools/dpdk-devbind.py --status


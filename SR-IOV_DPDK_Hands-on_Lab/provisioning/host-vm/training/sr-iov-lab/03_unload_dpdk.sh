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
#This script explictly binds the NICs at PCI addresses 00:09.0 and 00:0a.0 to the Intel kernel drivers. This is necessary so that we can find out what IP address has been allocated to the NIC ports.

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
DRIVER="i40evf"

insmod i40e
insmod i40evf
insmod ixgbe


echo "Binding $PCI_PORT_0 to $DRIVER"
python $RTE_SDK/tools/dpdk-devbind.py --bind=$DRIVER $PCI_PORT_0
echo "Binding $PCI_PORT_1 to $DRIVER"
python $RTE_SDK/tools/dpdk-devbind.py --bind=$DRIVER $PCI_PORT_1

rmmod igb_uio
rmmod cuse
rmmod fuse
rmmod uio
rmmod eventfd_link
rmmod ioeventfd

python $RTE_SDK/tools/dpdk-devbind.py --status

umount /mnt/huge

cat /proc/meminfo



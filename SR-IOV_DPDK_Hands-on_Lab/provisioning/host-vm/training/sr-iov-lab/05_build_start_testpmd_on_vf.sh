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

#This script re-builds DPDK and then launches testpmd. It expects to have the MAC address of the pktgen ethernet port passed as a command line parameter. The pktgen MAC address should have been displayed at the end of the previous step. See comments below for more information about the testpmd and DPDK parameters.

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

if [ "$RTE_SDK" == "" ]; then
	echo "Sorry, RTE_SDK env var has not been set to root of DPDK src tree"
	exit 1
fi

if [ "$RTE_TARGET" == "" ]; then
	echo "Sorry, RTE_TARGET env var has not been set to DPDK target build env"
	exit 1
fi

if [ "$1" == "" ]; then
        echo "Usage: $@ <MAC Address for pktgen ethernet port>"
        exit 1
fi

#-i -- interactive mode
#--burst=64 -- we are going to fetch 64 packets at at time
#--txd=2048/--rxd=2048 -- we want 2048 descriptors in the rx and tx rings
#--port-topology=chained -- we only have one port, so it has to do rx and tx
#--crc-strip -- necessary because we can't strip the CRC in a an SR-IOV scenario
#--forward=macswap -- when a packet arrives, swap the src and dest MAC addresses so that the packet returns to the sender
#--eth-peer=0,$1 -- pass the pktgen MAC address as the parameter
#--auto-start -- start retrieving packets immediately upon launch
TESTPMD_PARAMS="--burst=64 -i --txd=2048 --rxd=2048 --port-topology=chained --eth-peer=0,$1 --forward-mode=macswap --auto-start --crc-strip"

#-c 0x08 -- DPDK can run on cpu: 0000 1000
#-n 1 we only have one memory bank in this VM
#--pci-whitelist -- DPDK will only use the device at this PCI address
#--file-prefix testpmd -- when using the hugepage memory, prefix the filenames with 'testpmd' in order to keep the memory straight
DPDK_PARAMS="-c 0x06 -l 3,4 -n 1 --socket-mem 512 --file-prefix testpmd --pci-whitelist 00:09.0"

#make sure that DPDK has been built
cd $RTE_SDK
make config O=$RTE_TARGET T=$RTE_TARGET
cd $RTE_TARGET
make -j10

#build testpmd
cd $RTE_SDK/app/test-pmd
make -j10

$RTE_SDK/app/test-pmd/testpmd $DPDK_PARAMS -- $TESTPMD_PARAMS

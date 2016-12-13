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

#This script re-builds DPDK and then launches pktgen. See comments below for more details about parameters

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

#In these parameters, we lock pktgen to do 
# -m "[1:2].0" -- on port 0, core 1 does rx, core 2 does tx
# -P -- promiscuos mode
# -T -- colored terminal display mode
PKTGEN_PARAMS='-T -p 0x3 -P -m "[1:2].0"'

#-c 0x6 -- DPDK can run on cpus: 0000 0110
#-n 1 we only have one memory bank in this VM
#--pci-whitelist -- DPDK will only use the device at PCI address
#--socket-mem 512 -- 512M of memory for each socket
#--file-prefix pg -- prefix the hugepage memory files with a 'pg' prefix
DPDK_PARAMS="-c 0x06 -n 1 --proc-type auto --socket-mem 512 --file-prefix pg --pci-whitelist 00:0a.0"

#make sure that DPDK has been built
cd $RTE_SDK
make config O=$RTE_TARGET T=$RTE_TARGET
cd $RTE_TARGET
make -j10

export PKTGEN_DIR=/usr/src/pktgen-3.0.14
cd $PKTGEN_DIR
make -j10


./app/app/$RTE_TARGET/pktgen $DPDK_PARAMS -- $PKTGEN_PARAMS 


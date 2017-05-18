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

#-i -- interactive mode
#--burst=64: we are going to fetch 64 packets at at time
#--txd=2048/--rxd=2048: we want 2048 descriptors in the rx and tx rings
#--forward-mode=io: forward all packets received
#--auto-start: start forwarding packets immediately on launch
#--disable-hw-vlan: disable hardware VLAN
#--coremask=0xC0: lock tespmd to run on cores 6-7 (0b1100 0000)
export TESTPMD_PARAMS="--burst=64 -i --disable-hw-vlan --txd=2048 --rxd=2048 --forward-mode=io --auto-start --coremask=0xC0"

CMD="$DPDK_DIR/app/test-pmd/testpmd $DPDK_PARAMS -- $TESTPMD_PARAMS"
echo "Running $CMD"
$CMD

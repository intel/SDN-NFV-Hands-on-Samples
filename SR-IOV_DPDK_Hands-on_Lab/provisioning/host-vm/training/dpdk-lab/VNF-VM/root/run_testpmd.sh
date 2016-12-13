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

#This script launches the working version of testpmd in case the learner wants to see how the lab is supposed to work in the end. It locks DPDK to cores 2 and 3, and gives DPDK 512M of memory per socket. Then is starts testpmd with 64 byte packet bursts, and 2048 tx and rx descriptors.

DPDK_DIR=/root/dpdk-16.07

#not working testpmd
#cd $DPDK_DIR/app/testpmd

#working testpmd
cd $DPDK_DIR/app/test-pmd-working

./testpmd -c 0x6 -n 4 --socket-mem=512 -- --burst=64 -i --txd=2048 --rxd=2048 

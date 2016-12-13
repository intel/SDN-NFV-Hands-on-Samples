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

#This script launches pktgen. The parameters allow DPDK to run on CPUs 2-6, allocate 512M of memory per socket, and specify that the hugepage memory for this process should have prefix of 'pg' to distinguish it from other applications that might be using the hugepages. The pktgen parameters specify that it should run in promiscuous mode and that 

#	core 2 should handle port 0 rx
#	core 4 should handle port 0 tx
#	core 3 should handle port 1 rx
#	core 5 should handle port 1 tx

export PKTGEN_DIR=/root/pktgen-3.0.14
cd $PKTGEN_DIR
./app/app/x86_64-native-linuxapp-gcc/app/pktgen -c 0x3E -n 4 --proc-type auto --socket-mem 512 --file-prefix pg -- -T -p 0x3 -P -m "[2:4].0,[3:5].1"
 



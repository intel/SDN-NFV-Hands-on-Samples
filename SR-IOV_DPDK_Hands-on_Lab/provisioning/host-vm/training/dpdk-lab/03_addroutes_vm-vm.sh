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

#This script clears any existing flows, sets traffic flows in the following pattern, and then dumps the flows for debugging purposes:
# in port 2, out port 3
# in port 3, out port 2
# in port 1, out port 4
# in port 4, out port 1

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

export OVS_DIR=/usr/src/ovs-branch-2.6

cd $OVS_DIR

# Clear current flows 
./utilities/ovs-ofctl del-flows br0 
 
# Add Flow for port 0 to port 1 and port 1 to port 0 
./utilities/ovs-ofctl add-flow br0 in_port=2,dl_type=0x800,idle_timeout=0,action=output:3
./utilities/ovs-ofctl add-flow br0 in_port=3,dl_type=0x800,idle_timeout=0,action=output:2
./utilities/ovs-ofctl add-flow br0 in_port=1,dl_type=0x800,idle_timeout=0,action=output:4
./utilities/ovs-ofctl add-flow br0 in_port=4,dl_type=0x800,idle_timeout=0,action=output:1


./utilities/ovs-ofctl dump-flows br0

sleep 1

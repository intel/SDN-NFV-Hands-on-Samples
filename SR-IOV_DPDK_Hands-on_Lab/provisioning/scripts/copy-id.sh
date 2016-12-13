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

#This helper script copied my ssh public key to all of the systems in the entire cluster, both compute node, and Host, Tenant, and VNF VMs. Ideally, those SSH keys would be copied during the cloning and creation process; I just didn't figure that out until it was too late. I copied the user ssh keys rather than the root ssh keys so that ansible could be run as non-root user.

PREFIX="HostVM-"
MAX_NODES=55
i=0
while [ $i -le $MAX_NODES ]; do 
#if the current id is less than 10, prefix it with a 0
	if [ $i -lt 10 ]; then
		host=${PREFIX}0$i
	else
		host=${PREFIX}$i
	fi
	echo "Host=$host"
	ssh-copy-id $host 
	(( i++ ))
done

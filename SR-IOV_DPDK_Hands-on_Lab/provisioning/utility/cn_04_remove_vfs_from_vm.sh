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

#This script launches the remove_sr-iov_nics.yaml found in the ../roles directory, and then sleeps for 20 seconds to give each of the newly redefined domains adequate time to reboot before printing out the network bus information of each of the domains that previously had SR-IOV interfaces. See remove_sr-iov_nics.yaml documentation for more information about what that role does.

SCOPE=compute_nodes

#run the remove_sr-iov_nics.yaml role on all compute_nodes as defined in /etc/ansible/hosts; ask for the SUDO password before running, and launch 14 parallel processes
ansible-playbook ~/provisioning-master/roles/remove_sr-iov_nics.yaml -l $SCOPE -Kf14 

#This gives the newly redefined domains adequate time to boot
sleep 20

#run lshw on each of the SR-IOV VMs and display network device bus info
ansible sr-iov_vms -a "lshw -c network -businfo" -bK

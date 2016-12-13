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

#This script used the generic runScript.yaml Ansible role found in ../roles to run the 07_unload_all_x710_drivers.sh script from ../host-vm on each one of the HOSTVM systems. See the documentation for 07_unload_all_x710_drivers.sh for more information about what that script does. This script passes three parameters into the runScript.yaml role: 
#	dest_path: this variable is defined in runScript.yaml, but the command-line --extra-vars definition overrides that definition. It is the directory on the HostVM into which the script should be copied before it is run.
#	script_name: this is the name of the script, in this case 07_unload_all_x710_drivers.sh.
#	relative_source_path: this is the location of the script relative to provisioning_master_dir, which is defined in /etc/ansible/hosts. Thus, the location of the 07_unload_all_x710_drivers.sh script is {{ provisioning_master_dir }}/host-vm

PARAM="dest_path='/home/user/training/sr-iov-lab' script_name='07_unload_all_x710_drivers.sh' relative_source_path='host-vm'"

SCOPE="host_vms"

ansible-playbook ~/provisioning-master/roles/runScript.yaml -l $SCOPE -Kf14 --extra-vars "$PARAM"

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

#This script is optional and runs the following scripts:
# 01_start_ovs.sh
# 02_createports_ovs.sh
# 03_addroutes_vm-vm.sh
# 04_start_VNF-VM.sh
# 05_start_TenantVM.sh

if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi

SCRIPT_DIR=$(pwd)

echo "Starting OpenvSwitch..."
$SCRIPT_DIR/01_start_ovs.sh

echo "Creating OpenvSwitch ports..."
$SCRIPT_DIR/02_createports_ovs.sh

echo "Adding routes/flows..."
$SCRIPT_DIR/03_addroutes_vm-vm.sh

echo "Starting the VNF VM..."
$SCRIPT_DIR/04_start_VNF-VM.sh

echo "Starting the Tenant VM..."
$SCRIPT_DIR/05_start_TenantVM.sh

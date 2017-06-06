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

NIC_DIR="/sys/class/net"
declare -a PARENT_PF_PCI_INFO
declare -a VF_INTERFACE_INFO
declare -a PARENT_PF_DESCRIPTION_INFO
num_vfs=0
for i in $( ls $NIC_DIR) ; 
do
#	echo "Determining Physfn info for $i"
	if [ -L "${NIC_DIR}/$i/device/physfn" ]; then
		PARENT_PF_PCI=$( readlink "${NIC_DIR}/$i/device/physfn" | cut -d '/' -f2 )
		PARENT_PF_VENDOR=$( lspci -vmmks $PARENT_PF_PCI | grep ^Vendor | cut -f2) 
		PARENT_PF_NAME=$( lspci -vmmks $PARENT_PF_PCI | grep ^Device | cut -f2) 
		VF_INTERFACE_INFO[$num_vfs]="$i"
		PARENT_PF_PCI_INFO[$num_vfs]="$PARENT_PF_PCI"
		PARENT_PF_DESCRIPTION_INFO[$num_vfs]="$PARENT_PF_VENDOR $PARENT_PF_NAME"
		((num_vfs++))
	fi
done

if [[ $num_vfs -gt 0 ]]; then
	echo -e "VF Device\tParent PF PCI BDF\tParent PF Description"
	echo -e "=========\t=================\t====================="
	for (( i=0; i < $num_vfs; i++ )) ; 
	do
		echo -e "${VF_INTERFACE_INFO[$i]}\t\t${PARENT_PF_PCI_INFO[$i]}\t\t${PARENT_PF_DESCRIPTION_INFO[$i]}"
	done
	echo " "
fi

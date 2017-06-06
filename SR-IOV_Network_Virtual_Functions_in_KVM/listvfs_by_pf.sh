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
for i in $( ls $NIC_DIR) ; 
do
	if [ -d "${NIC_DIR}/$i/device" -a ! -L "${NIC_DIR}/$i/device/physfn" ]; then
		declare -a VF_PCI_BDF
		declare -a VF_INTERFACE
		k=0
		for j in $( ls "${NIC_DIR}/$i/device" ) ;
		do
			if [[ "$j" == "virtfn"* ]]; then
				VF_PCI=$( readlink "${NIC_DIR}/$i/device/$j" | cut -d '/' -f2 )
				VF_PCI_BDF[$k]=$VF_PCI
				#get the interface name for the VF at this PCI Address
				for iface in $( ls $NIC_DIR );
				do
					link_dir=$( readlink ${NIC_DIR}/$iface )
					if [[ "$link_dir" == *"$VF_PCI"* ]]; then
						VF_INTERFACE[$k]=$iface
					fi
				done
				((k++))
			fi
		done		
		NUM_VFs=${#VF_PCI_BDF[@]}
		if [[ $NUM_VFs -gt 0 ]]; then
			echo "Physical Function $i has the following virtual functions:"
			echo -e "PCI BDF\t\tInterface"
			echo -e "=======\t\t========="
			for (( l = 0; l < $NUM_VFs; l++ )) ;
			do
				echo -e "${VF_PCI_BDF[$l]}\t${VF_INTERFACE[$l]}"
			done
			unset VF_PCI_BDF
			unset VF_INTERFACE
			echo " "
		fi	
	fi
done

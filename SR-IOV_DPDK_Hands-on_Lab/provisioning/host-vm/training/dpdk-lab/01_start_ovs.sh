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


#01_start_ovs.sh cleans up any existing Open vSwitch processes and resources, and then launches Open vSwitch with DPDK using one 1 GB HugePage.
if [ "$(id -u)" != "0" ]; then
        echo "Sorry, you are not root."
        exit 1
fi


umount nodev /mnt/huge
#umount nodev /mnt/huge_2mb
mount -t hugetlbfs nodev /mnt/huge
#mount -t hugetlbfs nodev /mnt/huge_2mb -o pagesize=2MB
mount

#rmmod i40e
#rmmod ixgbe
rmmod igb_uio
rmmod cuse
rmmod fuse
rmmod openvswitch
rmmod uio
rmmod eventfd_link
rmmod ioeventfd
rm -rf /dev/vhost-net

modprobe uio
insmod $DPDK_BUILD/kmod/igb_uio.ko

export DPDK_DIR=/usr/src/dpdk-16.07
export DPDK_BUILD=$DPDK_DIR/x86_64-native-linuxapp-gcc
export OVS_DIR=/usr/src/ovs-branch-2.6
python $DPDK_DIR/tools/dpdk-devbind.py --status

# terminate OVS

pkill -9 ovs
rm -rf /usr/local/var/run/openvswitch
rm -rf /usr/local/etc/openvswitch/
rm -f /tmp/conf.db

mkdir -p /usr/local/etc/openvswitch
mkdir -p /usr/local/var/run/openvswitch

# initialize new OVS database

cd $OVS_DIR
./ovsdb/ovsdb-tool create /usr/local/etc/openvswitch/conf.db ./vswitchd/vswitch.ovsschema

#start database server
./ovsdb/ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
                 --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
                 --pidfile --detach

#initialize OVS database
./utilities/ovs-vsctl --no-wait init


#start OVS with DPDK portion using 1GB
./utilities/ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true other_config:dpdk-lcore-mask=0x2 other_config:dpdk-socket-mem="1024"

./vswitchd/ovs-vswitchd unix:/usr/local/var/run/openvswitch/db.sock --pidfile --detach

sleep 2

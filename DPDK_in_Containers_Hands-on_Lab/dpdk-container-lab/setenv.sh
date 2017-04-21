DPDK_VERSION="/home/user/dpdk-16.11"
export RTE_SDK="/home/user/dpdk"


echo "Checking for DPDK directory"
if [ ! -e $DPDK_VERSION ]; then
	echo "Unable to find the correct DPDK version in $DPDK_VERSION. Exiting"
	exit 1
fi

if [ ! -L $RTE_SDK ]; then
	echo "Creating symbolic link to DPDK directory"
	ln -s $DPDK_VERSION $RTE_SDK
fi

export RTE_TARGET="x86_64-native-linuxapp-gcc"
export DPDK_DIR=$RTE_SDK
export DPDK_BUILD=$RTE_TARGET
export OVS_DIR="/home/user/ovs"
export TRAINING_DIR="/home/user/training/dpdk-container-lab"
alias sudo='sudo -E'
echo "Done."

FROM ubuntu
COPY ./dpdk-container-lab /root/dpdk-container-lab
WORKDIR /root/dpdk-container-lab
COPY ./dpdk /usr/src/dpdk
ENV http_proxy=http://proxy-us.intel.com:911
ENV https_proxy=$http_proxy
ENV HTTP_PROXY=$http_proxy
ENV HTTPS_PROXY=$http-proxy
ENV NO_PROXY=intel.com,localhost
RUN apt-get update && apt-get install -y build-essential automake python-pip libcap-ng-dev gawk pciutils linux-headers-$(uname -a | awk '{print $3}') vim kmod
RUN pip install -U pip six
ENV DPDK_DIR "/usr/src/dpdk"
ENV DPDK_BUILD "x86_64-native-linuxapp-gcc"
ENV RTE_SDK "/usr/src/dpdk"
ENV RTE_TARGET "x86_64-native-linuxapp-gcc"
RUN ./build_dpdk.sh
RUN ./build_testpmd.sh
CMD ["/bin/bash"]

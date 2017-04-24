FROM dpdk-containers/testpmd
COPY ./dpdk-container-lab /root/dpdk-container-lab
WORKDIR /root/dpdk-container-lab
COPY ./dpdk /usr/src/dpdk
COPY ./pktgen /usr/src/pktgen
RUN apt-get update && apt-get install -y libpcap-dev
ENV PKTGEN_DIR "/usr/src/pktgen"
RUN ./build_pktgen.sh
CMD ["/bin/bash"]

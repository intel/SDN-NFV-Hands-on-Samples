FROM dpdk-containers/testpmd
COPY ./dpdk-container-lab /root/dpdk-container-lab
WORKDIR /root/dpdk-container-lab
COPY ./pktgen /usr/src/pktgen
ENV http_proxy=http://proxy-us.intel.com:911
ENV https_proxy=$http_proxy
ENV HTTP_PROXY=$http_proxy
ENV HTTPS_PROXY=$http-proxy
ENV NO_PROXY=intel.com,localhost,192.168.0.0/16,10.0.0.0/8
RUN apt-get update && apt-get install -y libpcap-dev
ENV PKTGEN_DIR "/usr/src/pktgen"
RUN ./build_pktgen.sh; exit 0 #for some reason, the first time always fails, so we do this twice (??)
RUN ./build_pktgen.sh
CMD ["/bin/bash"]

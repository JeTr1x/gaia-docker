FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    bash \
    sudo \
    ca-certificates \
    jq \
    grep \
    lsof \
    pciutils \
    nvtop \
    btop \
    && apt-get clean
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
RUN dpkg -i cuda-keyring_1.1-1_all.deb
RUN apt-get update
RUN apt-get -y install cuda-toolkit-12-8

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080 9068 9069

ENTRYPOINT ["/entrypoint.sh"]

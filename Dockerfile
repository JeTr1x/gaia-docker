FROM nvidia/cuda:12.8.0-devel-ubuntu22.04

RUN apt-get update && apt-get install -y \
    curl \
    bash \
    wget \
    sudo \
    ca-certificates \
    jq \
    grep \
    lsof \
    pciutils \
    nvtop \
    btop \
    && apt-get clean

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080 9068 9069

ENTRYPOINT ["/entrypoint.sh"]

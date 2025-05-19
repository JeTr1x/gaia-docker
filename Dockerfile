FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    bash \
    sudo \
    ca-certificates \
    jq \
    grep \
    lsof \
    && apt-get clean

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080 9068 9069

ENTRYPOINT ["/entrypoint.sh"]

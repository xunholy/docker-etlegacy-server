FROM ubuntu:latest

WORKDIR /etlegacy

RUN apt-get update && \
    apt-get install -y install build-essential

RUN apt-get install -y libudev-dev libwebp-dev

RUN apt-get install -y automake zlib1g nasm autoconf cmake git zip gcc g++ libtool git

RUN git clone https://github.com/etlegacy/etlegacy.git . && \
    cd etlegacy && \
    git fetch --tags --force && \
    ./easybuild.sh build -RPI -mod

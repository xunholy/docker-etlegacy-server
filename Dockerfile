FROM ubuntu:24.04

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /etlegacy

RUN apt-get update && \
    apt-get install -y \
    wget \
    unzip \
    vim

RUN wget -O binaries.gz https://www.etlegacy.com/download/file/700 --no-check-certificate && \
    gunzip binaries.gz && tar -xvf binaries && mv etlegacy-v2.83.2-x86_64/* .

RUN TMP_DIR=$(mktemp -d -t et260b-install-XXXX) && \
    cd $TMP_DIR && \
    wget https://cdn.splashdamage.com/downloads/games/wet/et260b.x86_full.zip --no-check-certificate && \
    unzip et260b.x86_full.zip && \
    ./et260b.x86_keygen_V03.run --noexec --target $TMP_DIR/extracted && \
    mv $TMP_DIR/extracted/**/*pak* /etlegacy/etmain/

COPY ./config/server.cfg /etlegacy/legacy/server.cfg

COPY ./config/start.sh /etlegacy/start.sh

EXPOSE 27960/udp

ENTRYPOINT [ "/etlegacy/start.sh" ]

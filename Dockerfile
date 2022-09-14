FROM ubuntu:latest

WORKDIR /etlegacy

RUN apt-get update && \
    apt-get install -y \
        wget \
        unzip \
        vim \
        libc6:armhf libstdc++6:armhf

# Use the latest RPi armv7 compatible binaries; Check download page for latest revision.
RUN wget -O binaries https://www.etlegacy.com/download/file/418 --no-check-certificate && \
    tar -xvf binaries && \
    mv etlegacy-v2.80.2-arm/* .

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

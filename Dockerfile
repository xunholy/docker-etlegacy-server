FROM ubuntu:24.04

ENV DEBIAN_FRONTEND noninteractive

# Create the non-root user that matches Kubernetes securityContext
RUN groupadd -g 1000 etlegacy && \
    useradd -m -u 1000 -g etlegacy etlegacy

WORKDIR /etlegacy

RUN apt-get update && \
    apt-get install -y \
    wget \
    unzip \
    vim

# Download and extract files as root, then fix ownership
RUN wget -O binaries.gz https://www.etlegacy.com/download/file/700 --no-check-certificate && \
    gunzip binaries.gz && tar -xvf binaries && mv etlegacy-v2.83.2-x86_64/* . && \
    chown -R 1000:1000 /etlegacy

RUN TMP_DIR=$(mktemp -d -t et260b-install-XXXX) && \
    cd $TMP_DIR && \
    wget https://cdn.splashdamage.com/downloads/games/wet/et260b.x86_full.zip --no-check-certificate && \
    unzip et260b.x86_full.zip && \
    ./et260b.x86_keygen_V03.run --noexec --target $TMP_DIR/extracted && \
    mv $TMP_DIR/extracted/**/*pak* /etlegacy/etmain/ && \
    chown -R 1000:1000 /etlegacy/etmain

# Copy files with correct ownership
COPY --chown=1000:1000 ./config/server.cfg /etlegacy/legacy/server.cfg
COPY --chown=1000:1000 ./config/start.sh /etlegacy/start.sh

# Ensure scripts are executable
RUN chmod +x /etlegacy/start.sh

# Switch to the non-root user
USER 1000:1000

EXPOSE 27960/udp

ENTRYPOINT [ "/etlegacy/start.sh" ]

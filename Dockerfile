# Stage 1: Build and extract files
FROM debian:bookworm AS builder

WORKDIR /etlegacy

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip tar rsync ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 etlegacy && useradd -m -u 1000 -g etlegacy etlegacy

# Download and extract etlegacy binaries
RUN wget -O binaries.gz https://www.etlegacy.com/download/file/700 && \
    gunzip binaries.gz && tar -xvf binaries && \
    mv etlegacy-v2.83.2-x86_64/* . && \
    chown -R 1000:1000 /etlegacy

# Download and extract ET 2.60b files
RUN wget -O et260b.zip https://cdn.splashdamage.com/downloads/games/wet/et260b.x86_full.zip && \
    unzip et260b.zip && \
    ./et260b.x86_keygen_V03.run --noexec --target extracted && \
    mv extracted/**/*pak* /etlegacy/etmain/ && \
    chown -R 1000:1000 /etlegacy/etmain

# Stage 2: Copy only necessary files to a minimal final image
FROM debian:bookworm

WORKDIR /etlegacy

COPY --from=builder --chown=1000:1000 /etlegacy /etlegacy
COPY --chown=1000:1000 ./config/server.cfg /etlegacy/legacy/default_server.cfg
COPY --chown=1000:1000 ./config/start.sh /etlegacy/start.sh

USER 1000:1000

EXPOSE 27960/udp

ENTRYPOINT ["/etlegacy/start.sh"]

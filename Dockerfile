# Stage 1: Build and extract files
FROM debian:bookworm AS builder

ARG ETL_FILE_ID=700
ARG ETL_VERSION=v2.83.2

WORKDIR /etlegacy

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip tar rsync ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 etlegacy && useradd -m -u 1000 -g etlegacy etlegacy

# Download and extract etlegacy binaries
# TODO: Update checksum when upgrading ETL version
RUN wget -O binaries.gz "https://www.etlegacy.com/download/file/${ETL_FILE_ID}" && \
    echo "d97b2a4be89b59924044d43e9391686b1b18919e32f97248d1b412235530ee67  binaries.gz" | sha256sum -c - && \
    gunzip binaries.gz && tar -xvf binaries && \
    mv "etlegacy-${ETL_VERSION}-x86_64"/* . && \
    chown -R 1000:1000 /etlegacy

# Download and extract ET 2.60b files
# Checksum for official Splash Damage ET 2.60b installer
RUN wget -O et260b.zip https://cdn.splashdamage.com/downloads/games/wet/et260b.x86_full.zip && \
    echo "2a8fef8e8558efffcad658bb9a8b12df8740418b3514142350eba3b7641eb3e0  et260b.zip" | sha256sum -c - && \
    unzip et260b.zip && \
    ./et260b.x86_keygen_V03.run --noexec --target extracted && \
    mv extracted/**/*pak* /etlegacy/etmain/ && \
    chown -R 1000:1000 /etlegacy/etmain

# Remove client binaries, build artifacts, and unnecessary files
RUN rm -f /etlegacy/etl.x86_64 /etlegacy/etl_bot.x86_64.sh \
    /etlegacy/*.so /etlegacy/binaries /etlegacy/et260b* \
    /etlegacy/COPYING /etlegacy/INSTALL \
    && rm -rf /etlegacy/extracted /etlegacy/etlegacy-v2.83.2-x86_64

# Stage 2: Copy only necessary files to a minimal final image
FROM debian:bookworm

WORKDIR /etlegacy

COPY --from=builder --chown=1000:1000 /etlegacy /etlegacy
COPY --chown=1000:1000 ./config/server.cfg /etlegacy/legacy/server.cfg
COPY --chown=1000:1000 ./config/start.sh /etlegacy/start.sh

USER 1000:1000

EXPOSE 27960/udp

ENTRYPOINT ["/etlegacy/start.sh"]

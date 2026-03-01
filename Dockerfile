# Stage 1: Build and extract files
FROM debian:bookworm AS builder

ARG ETL_FILE_ID=700
ARG ETL_VERSION=v2.83.2

WORKDIR /etlegacy

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip tar rsync ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 etlegacy && useradd -m -u 1000 -g etlegacy etlegacy

# Download and extract etlegacy binaries (architecture-aware)
ARG TARGETPLATFORM
RUN case "${TARGETPLATFORM}" in \
      "linux/amd64") ETL_URL="https://www.etlegacy.com/download/file/${ETL_FILE_ID}" ; ETL_ARCH="x86_64" ;; \
      "linux/arm64") ETL_URL="https://www.etlegacy.com/download/file/710" ; ETL_ARCH="aarch64" ;; \
      *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    wget -O binaries.gz "${ETL_URL}" && \
    gunzip binaries.gz && tar -xvf binaries && \
    mv "etlegacy-${ETL_VERSION}-${ETL_ARCH}"/* . && \
    chown -R 1000:1000 /etlegacy

# Download and extract ET 2.60b files
RUN wget -O et260b.zip https://cdn.splashdamage.com/downloads/games/wet/et260b.x86_full.zip && \
    echo "2a8fef8e8558efffcad658bb9a8b12df8740418b3514142350eba3b7641eb3e0  et260b.zip" | sha256sum -c - && \
    unzip et260b.zip && \
    ./et260b.x86_keygen_V03.run --noexec --target extracted && \
    mv extracted/**/*pak* /etlegacy/etmain/ && \
    chown -R 1000:1000 /etlegacy/etmain

# Remove client binaries, build artifacts, and unnecessary files
RUN rm -f /etlegacy/etl.* /etlegacy/etl_bot.* \
    /etlegacy/*.so /etlegacy/binaries /etlegacy/et260b* \
    /etlegacy/COPYING /etlegacy/INSTALL \
    && rm -rf /etlegacy/extracted /etlegacy/etlegacy-*/

# Stage 2: Runtime image
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends gettext-base && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /etlegacy

COPY --from=builder --chown=1000:1000 /etlegacy /etlegacy
COPY --chown=1000:1000 ./config/server.cfg.template /etlegacy/legacy/server.cfg.template
COPY --chown=1000:1000 ./config/start.sh /etlegacy/start.sh

ENV HOME=/etlegacy

USER 1000:1000

EXPOSE 27960/udp

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD test -d /proc/1/fd || exit 1

ENTRYPOINT ["/etlegacy/start.sh"]
CMD ["+set", "fs_game", "legacy", "+set", "fs_homepath", "/etlegacy", "+exec", "server.cfg"]

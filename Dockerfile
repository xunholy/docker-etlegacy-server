FROM alpine:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages (Alpine uses `apk` instead of `apt`)
RUN apk add --no-cache \
    wget \
    unzip \
    vim \
    shadow  # `shadow` provides user management tools like `useradd`

# Create the non-root user and group
RUN addgroup -g 1000 etlegacy && \
    adduser -D -u 1000 -G etlegacy etlegacy

WORKDIR /etlegacy

# Download and extract files
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

# Copy config files with correct ownership
COPY --chown=1000:1000 ./config/server.cfg /etlegacy/legacy/server.cfg
COPY --chown=1000:1000 ./config/start.sh /etlegacy/start.sh

RUN chmod +x /etlegacy/start.sh

# Run as non-root user
USER 1000:1000

EXPOSE 27960/udp

ENTRYPOINT [ "/etlegacy/start.sh" ]

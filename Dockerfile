# 🚀 Stage 1: Build and extract files
FROM alpine:latest AS builder

WORKDIR /etlegacy

# Install necessary tools
RUN apk add --no-cache wget unzip tar shadow

# Create user (must match Kubernetes securityContext)
RUN addgroup -g 1000 etlegacy && adduser -D -u 1000 -G etlegacy etlegacy

# Download and extract etlegacy binaries
RUN wget -O binaries.gz https://www.etlegacy.com/download/file/700 --no-check-certificate && \
    gunzip binaries.gz && tar -xvf binaries && \
    mv etlegacy-v2.83.2-x86_64/* . && \
    chown -R 1000:1000 /etlegacy

# Download and extract ET 2.60b files
RUN wget -O et260b.zip https://cdn.splashdamage.com/downloads/games/wet/et260b.x86_full.zip --no-check-certificate && \
    unzip et260b.zip && \
    ./et260b.x86_keygen_V03.run --noexec --target extracted && \
    mv extracted/**/*pak* /etlegacy/etmain/ && \
    chown -R 1000:1000 /etlegacy/etmain

# 🚀 Stage 2: Copy only necessary files to a minimal final image
FROM gcr.io/distroless/base-nonroot AS final

WORKDIR /etlegacy

# Copy necessary files from the builder stage
COPY --from=builder --chown=1000:1000 /etlegacy /etlegacy
COPY --from=builder /etlegacy/start.sh /etlegacy/start.sh

# Ensure the script is executable
RUN chmod +x /etlegacy/start.sh

# Use non-root user (must match match Kubernetes securityContext)
USER 1000:1000

EXPOSE 27960/udp

ENTRYPOINT [ "/etlegacy/start.sh" ]

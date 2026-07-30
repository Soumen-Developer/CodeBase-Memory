# codebase-memory-mcp — Production Docker image
#
# Runs the CBM daemon + HTTP UI (port 9749) inside a container.
# The daemon communicates via Unix-domain sockets on a shared volume.
#
# Build:  docker build -t codebase-memory-mcp .
# Run:    docker run -d --name cbm \
#           -p 9749:9749 \
#           -v cbm-runtime:/run/cbm \
#           -v cbm-cache:/root/.cache/codebase-memory-mcp \
#           -v $(pwd):/workspace \
#           codebase-memory-mcp

# ── Build stage ──────────────────────────────────────────────────────
FROM ubuntu:noble@sha256:4fbb8e6a8395de5a7550b33509421a2bafbc0aab6c06ba2cef9ebffbc7092d90 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    zlib1g-dev \
    ca-certificates \
    git \
    curl \
    python3 \
    ccache \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 (required for @tailwindcss/oxide and vitest)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update && apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Verify Node version
RUN node --version && npm --version

# Configure ccache
ENV CCACHE_DIR=/root/.ccache
ENV CCACHE_COMPILERCHECK=content
ENV PATH=/usr/lib/ccache:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /src

# Copy source
COPY . .

# Build with UI (includes frontend assets)
RUN scripts/build.sh --with-ui CC=gcc CXX=g++ BUILD_DIR=build/linux-amd64

# ── Runtime stage ────────────────────────────────────────────────────
FROM ubuntu:noble@sha256:4fbb8e6a8395de5a7550b33509421a2bafbc0aab6c06ba2cef9ebffbc7092d90

# Runtime deps: zlib (linked), ca-certs (for any HTTPS), libsqlite3 (vendored, not needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    zlib1g \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Runtime directories (daemon socket + cache)
RUN mkdir -p /run/cbm /root/.cache/codebase-memory-mcp

# Copy binary from builder
COPY --from=builder /src/build/linux-amd64/codebase-memory-mcp /usr/local/bin/codebase-memory-mcp

# Environment
ENV CBM_CACHE_DIR=/root/.cache/codebase-memory-mcp
ENV HOME=/root

# Expose HTTP UI port (default 9749, configurable via --port)
EXPOSE 9749

# Health check: verify HTTP UI responds
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -fsS http://127.0.0.1:9749/ >/dev/null || exit 1

# Entry point: start daemon in foreground with UI enabled
# The daemon will bind HTTP on 0.0.0.0:9749 inside container (accessible via -p 9749:9749)
# Unix socket lives on /run/cbm (mount a volume to share with host CLI if needed)
ENTRYPOINT ["codebase-memory-mcp"]
CMD ["--ui=true", "--port=9749"]
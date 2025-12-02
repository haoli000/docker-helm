# Multi-stage Dockerfile for Helm
# Usage: docker build --build-arg HELM_VERSION=v3.19.2 -t helm:v3.19.2 .
# Optional: docker build --build-arg ALPINE_VERSION=3.20 --build-arg HELM_VERSION=v3.19.2 -t helm:v3.19.2 .

ARG ALPINE_VERSION=latest

FROM alpine:${ALPINE_VERSION} AS downloader

ARG HELM_VERSION
ARG TARGETOS=linux
ARG TARGETARCH

# Install dependencies
RUN apk add --no-cache curl tar

# Download and verify Helm
WORKDIR /tmp
RUN set -ex && \
    case "${TARGETARCH}" in \
        amd64) HELM_ARCH="amd64" ;; \
        arm64) HELM_ARCH="arm64" ;; \
        arm) HELM_ARCH="arm" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    HELM_FILE="helm-${HELM_VERSION}-${TARGETOS}-${HELM_ARCH}.tar.gz" && \
    echo "Downloading Helm ${HELM_VERSION} for ${TARGETOS}-${HELM_ARCH}" && \
    curl -fsSL -o "${HELM_FILE}" "https://get.helm.sh/${HELM_FILE}" && \
    curl -fsSL -o "${HELM_FILE}.sha256sum" "https://get.helm.sh/${HELM_FILE}.sha256sum" && \
    cat "${HELM_FILE}.sha256sum" && \
    sha256sum -c "${HELM_FILE}.sha256sum" && \
    tar -xzf "${HELM_FILE}" && \
    mv ${TARGETOS}-${HELM_ARCH}/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    /usr/local/bin/helm version

# Final minimal image
ARG ALPINE_VERSION=latest
FROM alpine:${ALPINE_VERSION}

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    git \
    bash \
    curl \
    jq \
    && rm -rf /var/cache/apk/*

# Copy helm binary from downloader stage
COPY --from=downloader /usr/local/bin/helm /usr/local/bin/helm

# Create a non-root user
RUN addgroup -S helm && adduser -S helm -G helm
USER helm

WORKDIR /apps

# Verify installation
RUN helm version

ENTRYPOINT ["helm"]
CMD ["--help"]

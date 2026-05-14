FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    jq \
    shellcheck \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

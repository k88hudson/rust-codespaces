
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Load args
ARG FOLDER_BASENAME
ARG RUST_VERSION
RUN test -n "${RUST_VERSION}" || (echo "RUST_VERSION is not set in devcontainer.json" && exit 1) && \
 test -n "${FOLDER_BASENAME}" || (echo "FOLDER_BASENAME is not set in devcontainer.json" && exit 1)

ENV DEBIAN_FRONTEND=noninteractive

# Base dependencies
RUN apt-get update && apt-get install -y \
    clang curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Mise
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
RUN curl -fsSL https://mise.run | sh && \
  echo 'eval "$(mise activate bash)"' >> ~/.bashrc && \
  echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

# Install Rust
USER vscode

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
  | sh -s -- -y --default-toolchain "${RUST_VERSION}" && \
  echo '. $HOME/.cargo/env' >> $HOME/.bashrc && \
  echo '. $HOME/.cargo/env' >> $HOME/.zshrc
ENV PATH="$HOME/.cargo/bin:${PATH}"
RUN rustup component add rustfmt clippy && \
  rustup target add wasm32-unknown-unknown

# Install dependencies with mise
COPY mise.toml /workspaces/${FOLDER_BASENAME}/mise.toml
WORKDIR /workspaces/${FOLDER_BASENAME}
RUN mise trust && \
  mise install

# Copy manifests first to leverage Docker layer caching
WORKDIR /opt/prebuild
COPY Cargo.toml Cargo.lock ./
RUN cargo fetch

# Copy the full source and build
COPY . .
RUN cargo build --release && \
  cargo clippy

# Copy to prebuilt-target
RUN mkdir -p /opt/prebuilt-target && \
  rsync -a target/ /opt/prebuilt-target/

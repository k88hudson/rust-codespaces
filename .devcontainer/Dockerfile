# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Prefer stricter shells during RUN (fail on error, undefined vars, and pipe errors)
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Load args
ARG USERNAME=vscode
ARG CODESPACES_ENVIRONMENT=github
ARG FOLDER_BASENAME
ARG RUST_VERSION

ARG ARTIFACT_DIR=/opt/prebuild-artifacts

RUN \
  if [ $CODESPACES_ENVIRONMENT = "local" ]; then \
    mkdir -p /workspaces/${FOLDER_BASENAME} && \
    chown ${USERNAME}:${USERNAME} /workspaces/${FOLDER_BASENAME}; \
  elif [ ! -d /workspaces/${FOLDER_BASENAME} ]; then \
    echo "ERROR: /workspaces/${FOLDER_BASENAME} does not exist"; exit 1; \
  fi

# Ensure .bashrc and .zshrc exist
RUN touch /home/${USERNAME}/.bashrc /home/${USERNAME}/.zshrc

# Create the directory for copying the prebuilt target
RUN mkdir $ARTIFACT_DIR
RUN chown -R ${USERNAME}:${USERNAME} $ARTIFACT_DIR

# Base dependencies
ENV DEBIAN_FRONTEND=noninteractive
# RUN apt-get update && apt-get install -y \
#     clang curl ca-certificates \
#     && rm -rf /var/lib/apt/lists/*

USER ${USERNAME}

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
  | sh -s -- -y --default-toolchain "${RUST_VERSION}"
ENV PATH="/home/$USERNAME/.cargo/bin:${PATH}"
RUN rustup --version && cargo --version
RUN rustup component add rustfmt clippy && \
  rustup target add wasm32-unknown-unknown

# Mise
RUN curl -fsSL https://mise.run | sh
ENV PATH="/home/${USERNAME}/.local/bin:$PATH"
RUN mise --version

# Install dependencies with mise
COPY mise.toml /workspaces/${FOLDER_BASENAME}/mise.toml
WORKDIR /workspaces/${FOLDER_BASENAME}
RUN mise trust && \
  mise install

# Shell setup
RUN \
  for shell in bash zsh; do \
    # Rust
    echo '. ~/.cargo/env' >> /home/${USERNAME}/.${shell}rc && \
    # Mise
    echo "eval \"\$(mise activate ${shell})\"" >> /home/${USERNAME}/.${shell}rc; \
  done

# Pre-build the Rust project
WORKDIR /home/${USERNAME}/temp-src
COPY --chown=${USERNAME}:${USERNAME} . .
RUN cargo fetch
RUN cargo build --release
RUN cargo clippy
RUN cp -r target $ARTIFACT_DIR/target
RUN cp .devcontainer/prebuild.sh $ARTIFACT_DIR/prebuild.sh
RUN rm -rf /home/${USERNAME}/temp-src

# USER root
# WORKDIR /workspaces/${FOLDER_BASENAME}
# COPY --chown=${USERNAME}:${USERNAME} . .
# RUN $ARTIFACT_DIR/prebuild.sh
# USER vscode

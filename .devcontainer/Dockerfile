FROM mcr.microsoft.com/devcontainers/base:1-ubuntu-24.04

RUN apt-get update

USER vscode

RUN curl -fsSL https://mise.run | sh && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && \
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc && \
    echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc

ENV PATH="/home/vscode/.local/bin:/home/vscode/.cargo/bin:${PATH}"

WORKDIR /workspaces/$FOLDER_BASENAME

RUN mise install
RUN mise run compile

# GitLab Docs Workspace Docker image

FROM debian:12.2-slim

ARG ASDF_VERSION

# Install dependencies, including packages from the Brewfile.
# hadolint ignore=DL3015
RUN printf "\n\e[32mINFO: Installing dependencies..\e[39m\n" && apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    git \
    jq \
    libssl-dev \
    libyaml-dev \
    minify \
    yamllint \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install hadolint
RUN curl -L -o /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 \
    && chmod +x /bin/hadolint

# Create a user to run processes in Workspace Docker image
RUN useradd -l -u 5001 -G sudo -md /home/gitlab-workspaces -s /bin/bash -p gitlab-workspaces gitlab-workspaces
ENV HOME=/home/gitlab-workspaces
RUN mkdir -p /home/gitlab-workspaces && chgrp -R 0 /home && chmod -R g=u /etc/passwd /etc/group /home
USER 5001

# Install asdf and dependencies
# See https://asdf-vm.com/guide/getting-started.html#official-download
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v${ASDF_VERSION} && \
    echo ". $HOME/.asdf/asdf.sh" >> $HOME/.bashrc && \
    ASDF_DIR="${HOME}/.asdf" && . "${HOME}"/.asdf/asdf.sh && \
    # Add preview instructions when opening a terminal in a workspace
    echo "echo" >> $HOME/.bashrc && \
    echo "echo For information on how to preview documentation, see: \<https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/setup.md\>." >> $HOME/.bashrc

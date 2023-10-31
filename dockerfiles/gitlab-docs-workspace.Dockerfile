# GitLab Docs Workspace Docker image

FROM debian:12.1-slim

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

# Build the docs from this branch
COPY . /source/
WORKDIR /source

# Install asdf and dependencies
# See https://asdf-vm.com/guide/getting-started.html#official-download
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v${ASDF_VERSION} && \
    echo ". $HOME/.asdf/asdf.sh" >> /root/.bashrc && \
    ASDF_DIR="${HOME}/.asdf" && . "${HOME}"/.asdf/asdf.sh && \
    make setup && \
    bundle exec rake clone_repositories

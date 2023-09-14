# Base image for other Docker images
# Includes all system dependencies to build the GitLab Docs site
#
# Values for RUBY_VERSION and ALPINE_VERSION are defined in .gitlab-ci.yml
ARG RUBY_VERSION
ARG ALPINE_VERSION

FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION}

# Install dependencies
RUN printf "\n\e[32mINFO: Installing dependencies..\e[39m\n" && apk add --no-cache \
    bash        \
    build-base  \
    curl        \
    gcompat     \
    git         \
    gnupg       \
    grep        \
    gzip        \
    jq          \
    libcurl     \
    libxslt     \
    libxslt-dev \
    minify      \
    nodejs      \
    openssl     \
    pngquant    \
    ruby-dev    \
    tar         \
    xz          \
    xz-dev      \
    yarn        \
    && echo 'gem: --no-document' >> /etc/gemrc \
    && gem update --silent --system \
    && printf "\n\e[32mINFO: Dependency versions:\e[39m\n" \
    && echo "Ruby: $(ruby --version)" \
    && echo "RubyGems: $(gem --version)" \
    && echo "Node.js: $(node --version)" \
    && echo "Yarn: $(yarn --version)" \
    && printf "\n"

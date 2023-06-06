# GitLab Docs linting (HTML) Docker image
#
# Values for RUBY_VERSION and ALPINE_VERSION are defined in .gitlab-ci.yml
ARG RUBY_VERSION
ARG ALPINE_VERSION

FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION}

# Install dependencies
RUN printf "\n\e[32mINFO: Installing dependencies..\e[39m\n" && apk add --no-cache -U \
    bash        \
    build-base  \
    curl        \
    gcompat     \
    git         \
    gnupg       \
    grep        \
    gzip        \
    libcurl     \
    libxslt     \
    libxslt-dev \
    nodejs      \
    openssl     \
    parallel    \
    ruby-dev    \
    tar         \
    xz          \
    xz-dev      \
    yarn        \
    && echo 'gem: --no-document' >> /etc/gemrc \
    && gem update --system \
    && printf "\n\e[32mINFO: Dependency versions:\e[39m\n" \
    && echo "Ruby: $(ruby --version)" \
    && echo "RubyGems: $(gem --version)" \
    && echo "Node.js: $(node --version)" \
    && echo "Yarn: $(yarn --version)" \
    && printf "\n"

WORKDIR /tmp

# Fetch gitlab-docs
RUN printf "\n\e[32mINFO: Fetching gitlab-docs from main branch..\e[39m\n" \
  && wget --quiet https://gitlab.com/gitlab-org/gitlab-docs/-/archive/main/gitlab-docs-main.tar.bz2 \
  && tar xvjf gitlab-docs-main.tar.bz2 \
  && mv gitlab-docs-main gitlab-docs \
  && rm gitlab-docs-main.tar.bz2

WORKDIR /tmp/gitlab-docs/

# Install gitlab-docs dependencies
RUN printf "\n\e[32mINFO: Installing Node.js and Ruby dependencies..\e[39m\n" \
  && yarn install --frozen-lockfile \
  && yarn cache clean --all \
  && bundle update --bundler \
  && bundle install

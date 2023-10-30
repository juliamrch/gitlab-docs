# GitLab Docs linting (Markdown) Docker image
#
# Value for ALPINE_VERSION is defined in .gitlab-ci.yml
ARG ALPINE_VERSION

FROM alpine:${ALPINE_VERSION}

# Values for VALE_VERSION, MARKDOWNLINT_VERSION, and MARKDOWNLINT2_VERSION are defined in .gitlab-ci.yml
ARG VALE_VERSION
ARG MARKDOWNLINT_VERSION
ARG MARKDOWNLINT2_VERSION

# Install dependencies
RUN printf "\n\e[32mINFO: Installing dependencies..\e[39m\n" && apk add --no-cache \
    bash         \
    build-base   \
    curl         \
    git          \
    gnupg        \
    grep         \
    libc6-compat \
    libcurl      \
    libxslt      \
    libxslt-dev  \
    nodejs       \
    openssl      \
    pngquant     \
    ruby         \
    tar          \
    yarn         \
    && echo 'gem: --no-document' >> /etc/gemrc \
    && gem update --silent --system \
    && printf "\n\e[32mINFO: Dependency versions:\e[39m\n" \
    && echo "Ruby: $(ruby --version)" \
    && echo "RubyGems: $(gem --version)" \
    && echo "Node.js: $(node --version)" \
    && echo "Yarn: $(yarn --version)" \
    && printf "\n"

# Install Vale
RUN printf "\n\e[32mINFO: Installing Vale %s..\e[39m\n" "${VALE_VERSION}" \
  && wget --quiet https://github.com/errata-ai/vale/releases/download/v${VALE_VERSION}/vale_${VALE_VERSION}_Linux_64-bit.tar.gz \
  && tar -xvzf vale_${VALE_VERSION}_Linux_64-bit.tar.gz -C bin \
  && rm vale_${VALE_VERSION}_Linux_64-bit.tar.gz \
  && echo "Vale: $(vale --version)" \
  && printf "\n"

# Install markdownlint-cli
RUN printf "\n\e[32mINFO: Installing markdownlint-cli %s..\e[39m\n" "${MARKDOWNLINT_VERSION}" \
  && yarn global add markdownlint-cli@${MARKDOWNLINT_VERSION} && yarn cache clean \
  && echo "markdownlint-cli: $(markdownlint --version)" \
  && printf "\n"

# Install markdownlint-cli2
RUN printf "\n\e[32mINFO: Installing markdownlint-cli2 %s..\e[39m\n" "${MARKDOWNLINT2_VERSION}" \
  && yarn global add markdownlint-cli2@${MARKDOWNLINT2_VERSION} && yarn cache clean \
  && markdownlint-cli2 | head -n 1 \
  && printf "\n"

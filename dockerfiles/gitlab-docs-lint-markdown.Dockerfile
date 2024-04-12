# GitLab Docs linting (Markdown) Docker image
#
# Value for ALPINE_VERSION is defined in .gitlab-ci.yml
ARG ALPINE_VERSION

FROM alpine:${ALPINE_VERSION}

# Values for VALE_VERSION,  MARKDOWNLINT2_VERSION, and LYCHEE_VERSION are defined in .gitlab-ci.yml
ARG VALE_VERSION
ARG MARKDOWNLINT2_VERSION
ARG LYCHEE_VERSION

# Install dependencies
RUN printf "\n\e[32mINFO: Installing dependencies..\e[39m\n" \
    && apk update && apk upgrade --no-cache && apk add --no-cache bash git nodejs yarn \
    && printf "\n\e[32mINFO: Dependency versions:\e[39m\n" \
    && echo "Git: $(git --version)" \
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

# Install markdownlint-cli2 globally
RUN printf "\n\e[32mINFO: Installing markdownlint-cli2 %s..\e[39m\n" "${MARKDOWNLINT2_VERSION}" \
  && yarn global add markdownlint-cli2@${MARKDOWNLINT2_VERSION} && yarn cache clean \
  && markdownlint-cli2 | head -n 1 \
  && printf "\n"

# Install Lychee
RUN printf "\n\e[32mINFO: Installing Lychee %s..\e[39m\n" "${LYCHEE_VERSION}" \
  && wget --quiet https://github.com/lycheeverse/lychee/releases/download/v${LYCHEE_VERSION}/lychee-v${LYCHEE_VERSION}-x86_64-unknown-linux-musl.tar.gz \
  && tar -xvzf lychee-v${LYCHEE_VERSION}-x86_64-unknown-linux-musl.tar.gz -C bin \
  && rm lychee-v${LYCHEE_VERSION}-x86_64-unknown-linux-musl.tar.gz \
  && echo "Lychee: $(lychee --version)"

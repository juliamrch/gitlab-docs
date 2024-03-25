# Copy this Dockerfile to the root of each branch you want to create an archive
# and rename it to X.Y.Dockerfile, where X.Y the major.minor GitLab version.
#
#- Start of builder build stage -#
FROM ruby:3.2.3-alpine3.19 as builder

# Set versions as build args to fetch corresponding branches
ARG VER
ARG SEARCH_BACKEND
ARG GOOGLE_SEARCH_KEY
ARG NANOC_ENV

ENV CI_COMMIT_REF_NAME=$VER
ENV SEARCH_BACKEND=$SEARCH_BACKEND
ENV GOOGLE_SEARCH_KEY=$GOOGLE_SEARCH_KEY
ENV NANOC_ENV=$NANOC_ENV

# Install Nanoc dependencies and tools that
# are needed to build the docs site and run the tests.
RUN apk add --no-cache \
    bash        \
    build-base  \
    curl        \
    gcompat     \
    git         \
    gnupg       \
    go          \
    grep        \
    gzip        \
    jq          \
    libcurl     \
    libxslt     \
    libxslt-dev \
    minify      \
    nodejs      \
    npm         \
    openssl     \
    ruby-dev    \
    tar         \
    xz          \
    xz-dev      \
    && echo 'gem: --no-document' >> /etc/gemrc \
    && gem update --silent --system \
    # Add corepack for installing Yarn 4.x
    # https://github.com/nodejs/corepack?tab=readme-ov-file#manual-installs
    && npm uninstall -g yarn pnpm \
    && npm install -g corepack@0.24.1 \
    && printf "\n\e[32mINFO: Dependency versions:\e[39m\n" \
    && echo "Ruby: $(ruby --version)" \
    && echo "RubyGems: $(gem --version)" \
    && echo "Node.js: $(node --version)" \
    && echo "Yarn: $(yarn --version)" \
    && printf "\n"

# Build the docs from this branch
COPY . /source/
WORKDIR /source

RUN yarn install --immutable                          \
    && yarn cache clean                               \
    && bundle config set --local path 'vendor/bundle' \
    && bundle install                                 \
    && bundle exec rake default                       \
    && bundle exec nanoc compile -VV                  \
    && yarn compile:css                               \
    && yarn compile:js

RUN if [ "$SEARCH_BACKEND" = "lunr" ]; then make build-lunr-index; fi

# Run post-processing on archive:
#
# 1. Normalize the links in /source/public using version $VER.
# 2. Minify the files in /source/public into /dest, creating /dest/public. Must run last.
#    A trailing slash in the source path will copy all files inside the target directory,
#    while omitting the trainling slash will copy the directory as well.
#    We want the trailing slash. More info:
#    https://github.com/tdewolff/minify/blob/master/cmd/minify/README.md#directories
# 3. We move the end result to dest/<version>/, because of the way COPY works
#    in the next stage. If source is a directory, the entire contents of the
#    directory are copied, including filesystem metadata. The directory itself
#    is not copied, just its contents.
#    More info: https://docs.docker.com/engine/reference/builder/#copy
#
RUN scripts/normalize-links.sh public $VER    \
    && mkdir $VER                             \
    && scripts/minify-assets.sh $VER/ public/ \
    && mkdir dest                             \
    && mv $VER dest/

#- End of builder build stage -#

#- Start of NGINX stage -#
#
# Copy the ending HTML files from the previous 'builder' stage and copy them
# to an NGINX Docker image.
FROM nginx:stable-alpine

# Clean out any existing HTML files
RUN rm -rf /usr/share/nginx/html/*

# Copy the HTML from the builder stage to the default location for NGINX.
# The trailing slashes of the source and destination directories matter.
# https://docs.docker.com/engine/reference/builder/#copy
COPY --from=builder /source/dest/ /usr/share/nginx/html/

# Make an index.html and 404.html which will redirect / to /${VER}/
RUN echo "<html><head><title>Redirect for ${VER}</title><meta http-equiv=\"refresh\" content=\"0;url='/${VER}/'\" /></head><body><p>If you are not redirected automatically, click <a href=\"/${VER}/\">here</a>.</p></body></html>" > /usr/share/nginx/html/index.html \
    && echo "<html><head><title>Redirect for ${VER}</title><meta http-equiv=\"refresh\" content=\"0;url='/${VER}/'\" /></head><body><p>If you are not redirected automatically, click <a href=\"/${VER}/\">here</a>.</p></body></html>" > /usr/share/nginx/html/404.html

# Copy the NGINX config
COPY dockerfiles/nginx-overrides.conf /etc/nginx/conf.d/default.conf

# Start NGINX to serve the archive at / (which will redirect to the version-specific dir)
CMD ["sh", "-c", "echo 'GitLab docs are viewable at: http://0.0.0.0:4000'; exec nginx -g 'daemon off;'"]

#- End of NGINX stage -#

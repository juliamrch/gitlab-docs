#
# Copy this Dockerfile to the root of each branch you want to create an archive
# and rename it to X.Y.Dockerfile, where X.Y the major.minor GitLab version.
#

FROM ruby:3.2.2-alpine3.17 as builder

# Set versions as build args to fetch corresponding branches
ARG VER
ARG SEARCH_BACKEND
ARG GOOGLE_SEARCH_KEY
ARG NANOC_ENV

ENV CI_COMMIT_REF_NAME=$VER
ENV SEARCH_BACKEND=$SEARCH_BACKEND
ENV GOOGLE_SEARCH_KEY=$GOOGLE_SEARCH_KEY
ENV NANOC_ENV=$NANOC_ENV

#
# Install Nanoc dependencies and tools that
# are needed to build the docs site and run the tests.
#
RUN apk add --no-cache -U \
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

# Build the docs from this branch
COPY . /source/
WORKDIR /source

RUN yarn install --frozen-lockfile               \
    && yarn cache clean                          \
    && bundle config set --local deployment true \
    && bundle install                            \
    && bundle exec rake default                  \
    && bundle exec nanoc compile -VV             \
    && yarn compile:css

RUN if [ "$SEARCH_BACKEND" = "lunr" ]; then make build-lunr-index; fi

# Run post-processing on archive:
#
# 1. Normalize the links in /source/public using version $VER.
# 2. Compress images in /source/public.
# 3. Minify the files in /source/public into /dest, creating /dest/public. Must run last.
# 4. Rename /dest/public to /dest/$VER
RUN /source/scripts/normalize-links.sh /source/public $VER   \
    && /source/scripts/compress_images.sh /source/public     \
    && mkdir /dest                                           \
    && /source/scripts/minify-assets.sh /dest /source/public \
    && mv /dest/public "/dest/${VER}"

# Make an index.html and 404.html which will redirect / to /${VER}/
RUN echo "<html><head><title>Redirect for ${VER}</title><meta http-equiv=\"refresh\" content=\"0;url='/${VER}/'\" /></head><body><p>If you are not redirected automatically, click <a href=\"/${VER}/\">here</a>.</p></body></html>" > /dest/index.html \
    && echo "<html><head><title>Redirect for ${VER}</title><meta http-equiv=\"refresh\" content=\"0;url='/${VER}/'\" /></head><body><p>If you are not redirected automatically, click <a href=\"/${VER}/\">here</a>.</p></body></html>" > /dest/404.html

#- End of builder build stage -#

#- Start of NGINX stage -#
#
# Copy the ending HTML files from the previous 'builder' stage and copy them
# to an NGINX Docker image.
#
FROM nginx:stable-alpine

# Clean out any existing HTML files, and copy the HTML from the builder stage
# to the default location for NGINX.
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /dest /usr/share/nginx/html

# Copy the NGINX config
COPY dockerfiles/nginx-overrides.conf /etc/nginx/conf.d/default.conf

# Start NGINX to serve the archive at / (which will redirect to the version-specific dir)
CMD ["sh", "-c", "echo 'GitLab docs are viewable at: http://0.0.0.0:4000'; exec nginx -g 'daemon off;'"]

#- End of NGINX stage -#

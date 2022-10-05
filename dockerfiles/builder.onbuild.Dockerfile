# Get Nanoc bootstrap
FROM registry.gitlab.com/gitlab-org/gitlab-docs:bootstrap

# Make the variables of the archive Dockerfiles accessible to this build-stage
ONBUILD ARG VER
ONBUILD ARG NANOC_ENV
ONBUILD ARG CI_COMMIT_REF_NAME

# Build the docs from this branch
ONBUILD COPY . /source/
ONBUILD RUN NOKOGIRI_USE_SYSTEM_LIBRARIES=1 bundle install --jobs 4
ONBUILD RUN yarn install && yarn cache clean
ONBUILD RUN bundle exec rake default
ONBUILD RUN bundle exec nanoc compile -VV
## For 13.9 and later, there's a raketask that is run instead of the
## manual READMEs symlinking that is defined in scripts/normalize-links.sh.
## If the raketask is present, run it.
ONBUILD RUN if [ -f /scripts/check_symlinks.sh ]; then /scripts/check_symlinks.sh; else "/scripts/check_symlinks.sh not found"; fi

# Move generated HTML to /site
ONBUILD RUN mkdir /site
ONBUILD RUN mv public /site/${VER}

# Do some HTML post-processing on the archive
ONBUILD RUN if [ -f /scripts/normalize-links.sh ]; then /scripts/normalize-links.sh /site ${VER}; else "/scripts/normalize-links.sh not found"; fi

# Compress images
ONBUILD RUN if [ -f /scripts/compress_images.sh ]; then /scripts/compress_images.sh /site ${VER}; else "/scripts/compress_images.sh not found"; fi

# Minify assets
# ATTENTION: This should be the last script to run
ONBUILD RUN if [ -f /scripts/minify-assets.sh ]; then /scripts/minify-assets.sh /site ${VER}; else "/scripts/minify-assets.sh not found"; fi

# Make an index.html and 404.html which will redirect / to /${VER}/
ONBUILD RUN echo "<html><head><title>Redirect for ${VER}</title><meta http-equiv=\"refresh\" content=\"0;url='/${VER}/'\" /></head><body><p>If you are not redirected automatically, click <a href=\"/${VER}/\">here</a>.</p></body></html>" > /site/index.html
ONBUILD RUN echo "<html><head><title>Redirect for ${VER}</title><meta http-equiv=\"refresh\" content=\"0;url='/${VER}/'\" /></head><body><p>If you are not redirected automatically, click <a href=\"/${VER}/\">here</a>.</p></body></html>" > /site/404.html

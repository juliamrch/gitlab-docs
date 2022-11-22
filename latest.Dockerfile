FROM nginx:1.23.1-alpine

ENV TARGET=/usr/share/nginx/html

# Remove default Nginx HTML files
RUN rm -rf /usr/share/nginx/html/*

# Get all the archive static HTML and put it into place
# Copy the versions found in 'content/versions.json' under "current" and "last_minor"
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:15.6 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:15.5 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:15.4 ${TARGET} ${TARGET}

# List the two last major versions
# Copy the versions found in 'content/versions.json' under "last_major"
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:14.10 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:13.12 ${TARGET} ${TARGET}


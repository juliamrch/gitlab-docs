FROM nginx:1.25.4-alpine

ENV TARGET=/usr/share/nginx/html

# Remove default NGINX HTML files
RUN rm -rf /usr/share/nginx/html/*

# Get all the archive static HTML and put it into place
# Include the versions found in 'content/versions.json' under "current" and "last_minor"
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:17.1 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:17.0 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:16.11 ${TARGET} ${TARGET}

FROM nginx:1.23.1-alpine

ENV TARGET=/usr/share/nginx/html

# Remove default NGINX HTML files
RUN rm -rf /usr/share/nginx/html/*

# Get all the archive static HTML and put it into place
# Include the versions found in 'content/versions.json' under "current" and "last_minor"
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:16.8 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:16.7 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:16.6 ${TARGET} ${TARGET}

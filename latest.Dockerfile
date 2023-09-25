FROM nginx:1.23.1-alpine

ENV TARGET=/usr/share/nginx/html

# Remove default Nginx HTML files
RUN rm -rf /usr/share/nginx/html/*

# Get all the archive static HTML and put it into place
# Copy the versions found in 'content/versions.json' under "current" and "last_minor"
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:16.4 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:16.3 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:16.2 ${TARGET} ${TARGET}

FROM nginx:stable-alpine

ENV TARGET=/usr/share/nginx/html

## Get all the archive static HTML and put it into place
## Copy all the GitLab versions, except from the last one,
## which is still supported and online in docs.gitlab.com.
##
## List the versions from oldest to newest to make use of Docker's
## cache when building the final archives image.

## GitLab 13.X
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:13.0 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:13.1 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:13.2 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:13.3 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:13.4 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:13.5 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:13.6 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:13.7 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:13.8 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:13.9 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:13.10 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:13.11 ${TARGET} ${TARGET}
# GitLab 14.X
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:14.0 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:14.1 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:14.2 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:14.3 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:14.4 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:14.5 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:14.6 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:14.7 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:14.8 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:14.9 ${TARGET} ${TARGET}
# GitLab 15.X
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:15.0 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:15.1 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:15.2 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:15.3 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs:15.4 ${TARGET} ${TARGET}
# Don't add any more versions here. See the end of this file.

RUN rm -rf ${TARGET}/*.html

## When we start pushing the lunrjs images under the archives repository,
## the Registry repository will change to 'archives:X.Y'.
## The first supported version is 15.5.
## See https://gitlab.com/gitlab-org/gitlab-docs/-/issues/1255.
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs/archives:15.5 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs/archives:15.6 ${TARGET} ${TARGET}
COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs/archives:15.7 ${TARGET} ${TARGET}

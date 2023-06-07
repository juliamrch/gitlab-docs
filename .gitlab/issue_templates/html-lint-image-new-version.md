<!--
     Give the issue the title: "Update the html-lint Docker image"
-->

## Why

<!-- Give a brief explanation for why the new image is needed.
     Usually this is because of an update of the gitlab-svgs library.
     If this is the case, make sure to link to the MR that updated
     the library.
-->

## Update the `html-lint` Docker image

This issue is to track the work for upgrading the `html-lint` image.

1. Run the [`Build docker images manually` scheduled pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipeline_schedules),
   and run the following manual job after its test passes (you may cancel the irrelevant tests):
   - [ ] `image:docs-lint-html`

1. After the new image is built, get its name from the job that built it, and
   make sure it works as expected by first updating the relevant `image` entries in `gitlab-docs`:
   - [ ] <https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/.gitlab/ci/test.gitlab-ci.yml>

1. Update the the `image` entries in the upstream projects (search for `lint-html`):
   - [ ] GitLab (<https://gitlab.com/gitlab-org/gitlab/-/blob/master/.gitlab/ci/docs.gitlab-ci.yml>)
   - [ ] Omnibus GitLab (<https://gitlab.com/gitlab-org/omnibus-gitlab/-/blob/master/gitlab-ci-config/gitlab-com.yml>)
   - [ ] GitLab Runner (<https://gitlab.com/gitlab-org/gitlab-runner/-/blob/main/.gitlab/ci/test.gitlab-ci.yml>)
   - [ ] GitLab Chart (<https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/.gitlab-ci.yml>)
   - [ ] GitLab Operator (<https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/blob/master/.gitlab-ci.yml>)

/label ~"type::maintenance" ~"maintenance::refactor" ~"ci-build" ~"Category:Docs Site"

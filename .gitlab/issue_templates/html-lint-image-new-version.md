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
   update the `image` entry to the `test_global_nav_links` job in `gitlab-docs`:
   - [ ] <https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/.gitlab/ci/test.gitlab-ci.yml>

/label ~"type::maintenance" ~"maintenance::refactor" ~"ci-build" ~"Category:Docs Site"

## Ruby or Alpine version upgrade

This issue is to track the work for upgrading:

<!-- Delete either of the following if only upgrading one -->

- Ruby to version `version`
- Alpine to version `version`

To bump the versions of Ruby or Alpine:

1. Create a merge request to edit hardcoded versions in
   [`gitlab_kramdown` project](https://gitlab.com/gitlab-org/ruby/gems/gitlab_kramdown). Cut a new release.

1. After the `gitlab_kramdown` merge request is merged, create a merge request to:
   - Edit the hardcoded versions in these files:

     - [ ] `dockerfiles/single.Dockerfile`
     - [ ] `.gitpod.Dockerfile`
     - [ ] `.ruby-version`
     - [ ] `.tool-versions`

   -  [ ] Roll the version of `gitlab_kramdown` Gem forward.

1. In the same merge request, edit [`.gitlab-ci.yml`](.gitlab-ci.yml) to bump the environment variables:
   - [ ] `ALPINE_VERSION`
   - [ ] `RUBY_VERSION`
1. Before merging changes to `.tool-versions`, notify the team in the `#tw-team` channel of the change:

   ```plaintext
   I'm about to merge dependency changes to `gitlab-docs`. Run `make setup` to install the necessary updates.
   ```

   Then merge the merge request.
1. After the merge request is merged, run the [`Build docker images manually` scheduled pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipeline_schedules),
   and run the following manual jobs:

   - [ ] `image:gitlab-docs-base`
   - [ ] `image:docs-lint-markdown`
   - [ ] `image:docs-lint-html`

1. After the new images are built, make sure they work as expected by first updating
   the `image` entries in `gitlab-docs`:
   - [ ] <https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/.gitlab/ci/test.gitlab-ci.yml>
   - [ ] <https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/.gitlab/ci/rules.gitlab-ci.yml>

1. Update the the `image` entries in the upstream projects:

   - [ ] GitLab (<https://gitlab.com/gitlab-org/gitlab/-/blob/master/.gitlab/ci/docs.gitlab-ci.yml>)
   - [ ] Omnibus GitLab (<https://gitlab.com/gitlab-org/omnibus-gitlab/-/blob/master/gitlab-ci-config/gitlab-com.yml>)
   - [ ] GitLab Runner (<https://gitlab.com/gitlab-org/gitlab-runner/-/blob/main/.gitlab/ci/test.gitlab-ci.yml>)
   - [ ] GitLab Chart (<https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/.gitlab-ci.yml>)
   - [ ] GitLab Operator (<https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/blob/master/.gitlab-ci.yml>)
   - [ ] GitLab Development Kit (<https://gitlab.com/gitlab-org/gitlab-development-kit/-/blob/main/.gitlab/ci/test.gitlab-ci.yml>)
   - [ ] Gitaly (<https://gitlab.com/gitlab-org/gitaly/-/blob/master/.gitlab-ci.yml>)

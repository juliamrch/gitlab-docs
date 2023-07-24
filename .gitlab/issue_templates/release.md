<!--
SET TITLE TO: docs.gitlab.com release XX.ZZ (month, YYYY)
-->

## Tasks for all releases

Documentation [for handling the docs release](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md) is available.

Prerequisites:

- Make sure you have all the [needed tools](/doc/setup.md) installed on your system.

Terminology:

The following terms are used throughout this document:

- **Stable branch**: This is the branch that matches the GitLab version being released. For example,
  for GitLab 16.0, the stable branch is `16.0`.

### On the 21st of each month

1. [ ] Cross-link to the main MR for the release post: `<add link here>`
   ([Need help finding the MR?](https://gitlab.com/gitlab-com/www-gitlab-com/-/merge_requests?scope=all&state=opened&label_name%5B%5D=release%20post&label_name%5B%5D=blog%20post))
1. [ ] In this issue, create separate _threads_ for the retrospective, and add items as they appear:

   ```markdown
   ## :+1: What went well this release?
   ## :-1: What didn't go well this release?
   ## :chart_with_upwards_trend: What can we improve going forward?
   ```

1. Check for the stable branches that correspond with the release:
   - [ ] `gitlab`: <https://gitlab.com/gitlab-org/gitlab/-/branches?state=all&sort=updated_desc&search=stable-ee>
   - [ ] `gitlab-runner`: <https://gitlab.com/gitlab-org/gitlab-runner/-/branches?state=all&sort=updated_desc&search=-stable>
   - [ ] `omnibus-gitlab`: <https://gitlab.com/gitlab-org/omnibus-gitlab/-/branches?state=all&sort=updated_desc&search=-stable>
   - [ ] `charts/gitlab`: <https://gitlab.com/gitlab-org/charts/gitlab/-/branches?state=all&sort=updated_desc&search=-stable> (Version number is 9 lower than `gitlab` release, so GitLab 16.X = Charts 7.X)
1. [ ] When all the stable branches are available, [create a stable branch and Docker image for the release](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md#create-stable-branch-and-docker-image-for-release):

   1. [ ] In the root path of the `gitlab-docs` repository, update your local clone:

      ```shell
      make update
      ```

   1. [ ] Create the stable branch:

      ```shell
      make create-stable-branch
      ```

      - A branch `X.Y` for the release is created.
      - A new `X.Y.Dockerfile` is created and automatically committed.
      - The new branch is pushed.

      After the branch is created, the
      [`image:docs-single` job](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/7fbb5e1313ebde811877044e87f444a0a283fed4/.gitlab/ci/docker-images.gitlab-ci.yml#L107-129)
      runs and creates a new Docker image tagged with the name of the stable branch
      (for example, see [the 15.6 release pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines/702437095)).

You can continue onto the next process immediately, or wait for the release post.

### On the 22nd, or the first business day after

After the release post is live on the 22nd, or the next Monday morning if the release post happens on a weekend:

1. [ ] Verify that the [pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines?page=1&scope=all) for the stable branch (filter by branch)
   has passed and created a [Docker image](https://gitlab.com/gitlab-org/gitlab-docs/container_registry/631635?orderBy=NAME&sort=desc&search[]=)
   tagged with the release version. ([If it fails, how do I fix it?](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md#imagedocs-single-job-fails-when-creating-the-docs-stable-branch))
   - To filter the list of pipelines to the stable branch, select the **Branch name** filter then manually input the stable branch's name. For example, "Branch name = 16.0".
1. [ ] [Create a docs.gitlab.com release merge request](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md#create-release-merge-request)
   which updates the version dropdown menu for all online versions, updates the archives list, and adds
   the release to the Docker configuration.
1. Deploy the versions:
   1. [ ] Merge the docs release merge request.
   1. [ ] Go to the [scheduled pipelines page](https://gitlab.com/gitlab-org/gitlab-docs/-/pipeline_schedules)
      and run the `Build Docker images manually` pipeline.
   1. [ ] In the scheduled pipeline you just started, wait for the `test:image:docs-latest` job to finish, then manually run the `image:docs-latest`
      job that builds the `:latest` Docker image.
   1. [ ] When the `image:docs-latest` job is complete, run the `Build docs.gitlab.com every hour` scheduled pipeline.
1. [ ] After the deployment completes, open `docs.gitlab.com` in a browser. Confirm
   both the latest version and the correct pre-release version are listed in the documentation version dropdown.
1. [ ] Check all published versions of the docs to ensure they are visible and that their version menus have the latest versions.
1. [ ] Share the following message in the `#tw-team` channel:

   ```plaintext
   :mega: The docs <version> release is complete. If you have any feedback about this release, add it to the retro thread in <this issue>.
   ```

After the 22nd of each month:

1. [ ] Create a release issue for the next release, and assign it to the TW who completed the
   [release post structural check for the previous milestone](https://about.gitlab.com/handbook/product/ux/technical-writing/#regularly-scheduled-tasks).
1. [ ] **Major releases only.** Update
   [`OutdatedVersions.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/OutdatedVersions.yml)
   with the newly-outdated version.
1. [ ] Improve this checklist. Continue moving steps from
   [`releases.md`](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md)
   to here until the issue template is the single source of truth and the documentation provides extra information.

## Helpful links

- [Troubleshooting info](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md#troubleshooting)
- [List of upcoming assignees for overall release post](https://about.gitlab.com/handbook/marketing/blog/release-posts/managers/)
- [Internal docs for handling the docs release](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md)

/label ~"Technical Writing" ~"type::maintenance" ~"maintenance::refactor" ~"Category:Docs Site" ~release

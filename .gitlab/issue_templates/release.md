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
  for GitLab 17.2, the stable branch is `17.2`.

### On Monday the week of the release

1. [ ] Cross-link to the main MR for the release post: `<add link here>`
   ([Need help finding the MR?](https://gitlab.com/gitlab-com/www-gitlab-com/-/merge_requests?scope=all&state=opened&label_name%5B%5D=release%20post&label_name%5B%5D=release))
1. [ ] In this issue, create separate **threads** for the retrospective, and add items as they appear:

   ```markdown
   ## :+1: What went well this release?
   ## :-1: What didn't go well this release?
   ## :chart_with_upwards_trend: What can we improve going forward?
   ```

1. [ ] Add the version to be removed from the dropdown to the [docs archives](https://gitlab.com/gitlab-org/gitlab-docs-archives). This
   would be the oldest version from the `last_minor` hash in
   [`versions.json`](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/content/versions.json#L5).

   1. Edit [`archives.Dockerfile`](https://gitlab.com/gitlab-org/gitlab-docs-archives/-/blob/main/archives.Dockerfile)
      and add a new line at the end of the file with the archived version. It should read like:

      ```dockerfile
      COPY --from=registry.gitlab.com/gitlab-org/gitlab-docs/archives:<version> ${TARGET} ${TARGET}
      ```

   1. Create the merge request in `gitlab-org/gitlab-docs-archives` and merge it.

1. [Create a stable branch and Docker image for the release](#create-a-stable-branch-and-docker-image-for-the-release).

#### Create a stable branch and Docker image for the release

1. [ ] In the root path of the `gitlab-docs` repository:

   - Update your local clone:

     ```shell
     make update
     ```

   - Install all project dependencies:

     ```shell
     make setup
     ```

1. [ ] To practice running the task and check the process, run the Rake task in dry run mode:

   ```shell
   DRY_RUN=true make create-stable-branch
   ```

1. [ ] Create the stable branch:

   ```shell
   make create-stable-branch
   ```

   - A branch `X.Y` for the release is created.
   - A new `X.Y.Dockerfile` is created and automatically committed.
   - The new branch is pushed.
   - Do not create an MR for this step. This file is only used when a stable branch pipeline is run.

### On the Thursday of the release, or the day after

After the release post is live, or the day after:

1. Check that the stable branches that correspond with the release are present:
   - [ ] `gitlab`: <https://gitlab.com/gitlab-org/gitlab/-/branches?state=all&sort=updated_desc&search=stable-ee>
   - [ ] `gitlab-runner`: <https://gitlab.com/gitlab-org/gitlab-runner/-/branches?state=all&sort=updated_desc&search=-stable>
   - [ ] `omnibus-gitlab`: <https://gitlab.com/gitlab-org/omnibus-gitlab/-/branches?state=all&sort=updated_desc&search=-stable>
   - [ ] `charts/gitlab`: <https://gitlab.com/gitlab-org/charts/gitlab/-/branches?state=all&sort=updated_desc&search=-stable> (Version number is 9 lower than `gitlab` release, so GitLab 17.X = Charts 8.X)

   If not, you cannot proceed to the next step, so you'll have to wait.
1. [ ] Run a new pipeline targeting the docs stable branch after all upstream
   stable branches have been created. When the pipeline runs, the
   [`image:docs-single` job](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/7fbb5e1313ebde811877044e87f444a0a283fed4/.gitlab/ci/docker-images.gitlab-ci.yml#L107-129)
   builds a new Docker image tagged with the name of the stable branch containing
   all the versioned documentation
   (for example, see [the 15.6 release pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines/702437095)).

   Verify that the [pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines?page=1&scope=all) for the stable branch (filter by branch)
   has passed and created a [Docker image](https://gitlab.com/gitlab-org/gitlab-docs/container_registry/631635?orderBy=NAME&sort=desc&search[]=)
   tagged with the release version. ([If it fails, how do I fix it?](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md#imagedocs-single-job-fails-when-creating-the-docs-stable-branch))
   - To filter the list of pipelines to the stable branch, select the **Branch name** filter then manually input the stable branch's name. For example, "Branch name = 17.2".
1. Create a docs.gitlab.com release merge request, which updates the version dropdown menu for all online versions, updates the archives list, and adds the release to the Docker configuration:

   1. [ ] In the root path of the `gitlab-docs` repository, update your local clone:

      ```shell
      make update
      ```

   1. [ ] Create a branch `release-X-Y`. For example:

      ```shell
      git checkout -b release-17-2
      ```

   1. [ ] In `content/versions.json`, update the lists of versions to reflect the new release in the Versions menu:

      - Set `next` to the version number of the next release. For example, if you're releasing `17.2`, set `next` to `17.3`.
      - Set `current` to the version number of the release you're releasing. For example, if you're releasing `17.2`, set
      `current` to `17.2`.
      - Set `last_minor` to the last two most recent minor releases. For example, if you're
      releasing `17.2`, set `last_minor` to `17.1` and `17.0`.
      - Ensure `last_major` is set to the two most recent major versions. Do not include the current major version.
      For example, if you're releasing `17.2`, ensure `last_major` are `16.11` and `15.11`.

      As a complete example, the `content/versions.json` file for the `17.2` release is:

      ```json
      [
        {
          "next": "17.3",
          "current": "17.2",
          "last_minor": ["17.1", "17.0"],
          "last_major": ["16.11", "15.11"]
        }
      ]
      ```

   1. [ ] In `latest.Dockerfile`, remove the oldest version, then add the newest version to the top of the list.

   1. [ ] In [`.gitlab/ci/docker-images.gitlab-ci.yml`](../.gitlab/ci/docker-images.gitlab-ci.yml),
      under the `test:image:docs-single:` job, change the `GITLAB_VERSION` variable
      to the version number of the release you're releasing.

   1. [ ] Commit and push to create the merge request (but without running any `lefhook` tests). For example:

      ```shell
      git add .gitlab/ci/docker-images.gitlab-ci.yml content/versions.json latest.Dockerfile
      git commit -m "Docs release 17.2"
      LEFTHOOK=0 git push origin release-17-2
      ```

   1. [ ] Create the merge request, then:
      - Add the `~release` label.
      - Mark the merge request as **Draft**.
      - Verify that the **Changes** tab includes the following files:
        - `.gitlab/ci/docker-images.gitlab-ci.yml`
        - `content/versions.json`
        - `latest.Dockerfile`
1. Deploy the versions:
   1. [ ] Mark the docs release merge request as ready, and merge it.
   1. [ ] Go to the [scheduled pipelines page](https://gitlab.com/gitlab-org/gitlab-docs/-/pipeline_schedules)
      and run the `Build Docker images manually` pipeline.
   1. [ ] In the scheduled pipeline you just started, wait for the `test:image:docs-latest` job to finish, then manually run the `image:docs-latest`
      job that builds the `:latest` Docker image.
   1. [ ] When the `image:docs-latest` job is complete,
      go back to the [scheduled pipelines page](https://gitlab.com/gitlab-org/gitlab-docs/-/pipeline_schedules)
      and run the `Build docs.gitlab.com every hour` scheduled pipeline.
1. [ ] After the deployment completes, open `docs.gitlab.com` in a browser. Confirm
   both the latest version and the correct pre-release version are listed in the documentation version dropdown.
1. [ ] Check the version dropdown list to ensure all versions of the docs are visible and their version menus have the expected versions.
   - Versions hosted on `docs.gitlab.com` should show the same version options as the pre-release site.
   - Versions hosted on `archives.docs.gitlab.com` should only show their own version and a link back to the archives page.
     - This applies to v15.6 and newer; older versions may have broken links in the dropdown. This will eventually be resolved as the older versions are phased out.
1. [ ] Share the following message in the `#tw-team` channel:

   ```plaintext
   :mega: The docs <version> release is complete. If you have any feedback about this release, add it to the retro thread in <this issue>.
   ```

After the docs release is complete:

1. [ ] Create a release issue for the next release, and assign it to the TW who completed the
   [release post structural check for the current milestone](https://handbook.gitlab.com/handbook/marketing/blog/release-posts/managers/).
1. [ ] **Major releases only.** Update
   [`OutdatedVersions.yml`](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/OutdatedVersions.yml)
   with the newly-outdated version.
1. [ ] Improve this checklist. Continue moving steps from
   [`releases.md`](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md)
   to here until the issue template is the single source of truth and the documentation provides extra information.

## Helpful links

- [Troubleshooting info](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md#troubleshooting)
- [List of upcoming assignees for overall release post](https://handbook.gitlab.com/handbook/marketing/blog/release-posts/managers/)
- [Internal docs for handling the docs release](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md)

/label ~"Technical Writing" ~"type::maintenance" ~"maintenance::refactor" ~"Category:Docs Site" ~release

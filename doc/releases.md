# Monthly documentation releases

When a new GitLab version is released on the third Thursday of the month, we release version-specific published
documentation for the new version.

The tasks described in this document cover the preparation steps and the publication steps. The
preparation steps are completed on your local computer. The publication steps are completed in the
GitLab UI.

When you've completed the documentation release process:

- The [online published documentation](https://docs.gitlab.com) includes:
  - The three most recent minor releases of the current major version. For example 13.9, 13.8, and
    13.7.
  - The most recent minor releases of the last two major versions. For example 12.10, and 11.11.
- Documentation updates after the third Thursday of the month are for the next release.

Each documentation release:

- Has a dedicated branch, named in the format `XX.yy`.
- Has a Docker image that contains a build of that branch.

For example:

- For [GitLab 13.9](https://docs.gitlab.com/13.9/index.html), the
  [stable branch](https://gitlab.com/gitlab-org/gitlab-docs/-/tree/13.9) and Docker image:
  [`registry.gitlab.com/gitlab-org/gitlab-docs:13.9`](https://gitlab.com/gitlab-org/gitlab-docs/container_registry/631635).
- For [GitLab 13.8](https://docs.gitlab.com/13.8/index.html), the
  [stable branch](https://gitlab.com/gitlab-org/gitlab-docs/-/tree/13.8) and Docker image:
  [`registry.gitlab.com/gitlab-org/gitlab-docs:13.8`](https://gitlab.com/gitlab-org/gitlab-docs/container_registry/631635).

## Recommended timeline

To minimize problems during the documentation release process, use the following timeline:

- Complete the preparation steps in the week before the release. **All** of the following steps
  must be completed successfully before proceeding with the publication steps:

  1. If an issue was not already created for you by the TW that handled the last release,
     [create an issue for the release](https://gitlab.com/gitlab-org/gitlab-docs/-/issues/new?issuable_template=release)
     to track your progress and ensure completeness.
  1. Check that the stable branches have been created in all 4 projects. For details, see "Check for
     the stable branches that correspond with the release" in the docs release issue. When all
     stable branches are available, proceed with the next step.
  1. Create a stable branch and Docker image for the new version. For details, see "Create a stable
     branch and Docker image for the release" in the docs release issue.

- Complete the publication steps on the third Thursday of the month, after the release post is live:

  1. [Create a release merge request](#create-release-merge-request) for the new version, which
     updates the versions list (`versions.json`) for the current documentation
     and adds the release to the Docker configuration.

  1. [Merge the release merge request and run the necessary Docker image builds](#merge-the-release-merge-request-and-run-the-docker-image-builds).

### Optional. Test locally

Prerequisite:

- Install Docker. To verify, run `which docker`.

1. Build the image and run it. For example, for GitLab 15.0 documentation:

   ```shell
   docker build -t docs:15.0 -f 15.0.Dockerfile .
   docker run -it --rm -p 4000:4000 docs:15.0
   ```

   If you get a permission error, try running the commands prefixed with `sudo`.

   If you're informed that the Docker daemon isn't running, start it manually:

      - (MacOS) `dockerd` ([read more](https://docs.docker.com/config/daemon/#start-the-daemon-manually)).
      - (Linux) `sudo systemctl start docker` ([read more](https://docs.docker.com/config/daemon/systemd/#start-manually)).

1. Visit `http://localhost:4000/15.0` to see if everything works correctly.
1. Stop the Docker container:
   1. Identify the container's ID with `docker container ls`.
   1. Run `docker stop <container ID>`.

## Create release merge request

**Note:** An [epic is open](https://gitlab.com/groups/gitlab-org/-/epics/4361) to automate this step.

To create the release merge request for the release:

1. Make sure you're in the root path of the `gitlab-docs` repository.
1. Update your local clone:

   ```shell
   make update
   ```

1. Create a branch `release-X-Y`. For example:

   ```shell
   git checkout -b release-15-0
   ```

1. Edit `content/versions.json` and update the lists of versions to reflect the new release in the Versions menu:

   - Set `next` to the version number of the next release. For example, if you're releasing `15.2`, set `next` to `15.3`.
   - Set `current` to the version number of the release you're releasing. For example, if you're releasing `15.2`, set
     `current` to `15.2`.
   - Ensure `last_major` is set to the two most recent major versions. Do not include the current major version.
     For example, if you're releasing `15.2`, ensure `last_major` is `14.10` and `13.12`.
   - Set `last_minor` to the last two most recent minor releases. For example, if you're
     releasing `15.2`, set `last_minor` to `15.1` and `15.0`.

   As a complete example, the `content/versions.json` file for the `15.2` release is:

   ```json
   [
     {
       "next": "15.3",
       "current": "15.2",
       "last_minor": ["15.1", "15.0"],
       "last_major": ["14.10", "13.12"]
     }
   ]
   ```

1. Edit `latest.Dockerfile` by removing the oldest version, and then adding the newest version to the top of the list.
1. Open [`.gitlab/ci/docker-images.gitlab-ci.yml`](../.gitlab/ci/docker-images.gitlab-ci.yml)
   and edit the `test:image:docs-single:` job to change the `GITLAB_VERSION` variable.
   Set it to the version number of the release you're releasing.

1. Commit and push to create the merge request. For example:

   ```shell
   git add .gitlab/ci/docker-images.gitlab-ci.yml content/versions.json latest.Dockerfile
   git commit -m "Docs release 15.0"
   git push origin release-15-0
   ```

1. Create the merge request, then:
   - Add the `~release` label.
   - Mark the merge request as **Draft**.
   - Verify that the **Changes** tab includes the following files:
     - `.gitlab/ci/docker-images.gitlab-ci.yml`
     - `content/versions.json`
     - `latest.Dockerfile`

## Merge the release merge request and run the Docker image builds

_Do this after the release post is live._

1. Verify that the [pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines?page=1&scope=all) for the stable branch (filter by branch)
   has passed and created a [Docker image](https://gitlab.com/gitlab-org/gitlab-docs/container_registry/631635?orderBy=NAME&sort=desc&search[]=).
1. Open the [docs release merge request](#create-release-merge-request), mark it ready (that is, not draft), and merge it.
1. Go to the [scheduled pipelines page](https://gitlab.com/gitlab-org/gitlab-docs/-/pipeline_schedules)
   and run the `Build docker images manually` pipeline.
1. In the scheduled pipeline you just started, manually run the **image:docs-latest** job that builds the `:latest` Docker image.
1. When the pipeline is complete, run the `Build docs.gitlab.com every hour` scheduled pipeline to deploy all new versions to the public documentation site.
   You don't need to run any jobs manually for this second pipeline.

## Post-deployment checklist

After the documentation is released, verify the documentation site has been deployed as expected.
Open site `docs.gitlab.com` in a browser and confirm both the latest version and the correct `pre-`
version are listed in the documentation version dropdown.

For example, if you released the 14.1 documentation, the first dropdown entry should be
`14.2`, followed by `14.1`.

## Troubleshooting

### `compile_prod` job fails when creating the docs stable branch

When you create the stable branch in the `gitlab-docs` project, the `compile_prod` job might fail.

This happens if stable branches have not been
created for all the related projects. Some of the stable branches are
created close to the third Thursday of the month, so you might need to run the pipeline of the
stable branch one more time before the release.

The error is similar to the following:

```shell
fatal: couldn't find remote ref heads/6-10-stable
error: pathspec 'FETCH_HEAD' did not match any file(s) known to git
fatal: your current branch '6-10-stable' does not have any commits yet
```

**Solution**: run a [new pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines/new)
targeting the docs stable branch after all upstream stable branches have been created.

### `image:docs-single` job fails when creating the docs stable branch

There are generally two reasons why the `image:docs-single` job might fail:

- **Not all upstream stable branches are created yet**

   The error is similar to the [`compile_prod` job failure](#compile_prod-job-fails-when-creating-the-docs-stable-branch),
   and might looks like this:

   ```shell
   Cloning into '../gitlab-runner'...
   warning: Could not find remote branch 15-6-stable to clone.
   fatal: Remote branch 15-6-stable not found in upstream origin
   ```

   **Solution**: run a [new pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines/new)
targeting the docs stable branch after all upstream stable branches have been created.

- **The navigation menu contains broken links**

  The `image:docs-single` job may fail when the `gitlab-docs` repository contains
  changes to the navigation menu, but the corresponding page changes in the `gitlab`
  repository didn't make it into the release. This can happen close to the cutoff for
  the release. For example:

  1. On the 19th, a merge request in `gitlab` is merged, but the GitLab release doesn't include commits from that merge request. The cutoff for the
     release occurred on the 18th.
  1. A navigation menu item in `gitlab-docs` is also merged on the 19th.
  1. The `gitlab-docs` stable branch is created on the 20th, and includes the navigation menu changes.
  1. The link checker fails, because when building the Docker image, it pulls the
     stable branch from `gitlab`. This branch doesn't have the new content added on
     the 19th (first step), but the stable branch in `gitlab-docs` has the navigation menu changes.

  **Solution**: revert the navigation menu change in the `gitlab-docs` stable branch:

  1. Find the change to the navigation menu in
     [the list of recently merged MRs](https://gitlab.com/gitlab-org/gitlab-docs/-/merge_requests?scope=all&state=merged)
     for the `gitlab-docs` repository
  1. In the **Overview** tab, select **Revert** and target the `gitlab-docs` stable branch.

  Here's an example of hunting down a broken link of the navbar:

  1. [Filtering](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines?page=1&scope=all&ref=15.6)
     the pipelines for 15.6, we can see the
     [failed job](https://gitlab.com/gitlab-org/gitlab-docs/-/jobs/3341220987), which
     includes errors like:

     ```plaintext
     [ ERROR ] internal_links - broken reference to file:///ee/integration/glab/
     ```

     This means that a new global nav item made it into `gitlab-docs` 15.6 branch,
     but didn't in the counterpart `15-6-stable-ee` in `gitlab`.

  1. The next step is to find the offending MRs. One option is to look at the
     `navigation.yaml`, since we know this is where the error lies. Using the
     [blame](https://gitlab.com/gitlab-org/gitlab-docs/-/blame/main/content/_data/navigation.yaml)
     button, we can see who committed the `integration/glab/` entry.
     ![Offending commit](https://gitlab.com/gitlab-org/gitlab-docs/uploads/e74554ca538d8c990c14a29bca52ec6c/Screenshot_2022-11-22_at_21-31-33_Blame___content__data_navigation.yaml___main___GitLab.org___GitLab_Docs___GitLab.png)

     Clicking on the commit message, we can find
     [the related MR](https://gitlab.com/gitlab-org/gitlab-docs/-/merge_requests/3284).
     For this particular one, there's no related content MR in the description,
     but there's another link pointing to <https://gitlab.com/gitlab-org/cli/-/issues/1101>.
     From the related MRs, we can finally find the
     [content MR](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/104282).

  1. Now that we have found both the nav MR and the content MR, we can verify
     that the content MR didn't make it into the `gitlab` stable branch. The
     stable branches are named after the scheme `X-Y-stable-ee`, so searching
     the [commits of
     `15-6-stable-ee`](https://gitlab.com/gitlab-org/gitlab/-/commits/15-6-stable-ee/)
     shows that <https://gitlab.com/gitlab-org/gitlab/-/merge_requests/104282>
     indeed didn't make it into the stable branch (you can quickly check the
     dates of the commits and the date the MR was merged and compare).

  1. The next step is to revert the nav MR into the `15.6` branch of
     `gitlab-docs`. For that, we go to
     <https://gitlab.com/gitlab-org/gitlab-docs/-/merge_requests/3284>, click the
     Revert button, and select the `15.6` branch from the dropdown.
     The [revert MR](https://gitlab.com/gitlab-org/gitlab-docs/-/merge_requests/3298)
     is then created.

  1. After the revert MR is merged, we know that the 15.6 docs branch will pass the
     tests. So, we [run a new pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines/new)
     targeting the `15.6` branch.
  1. After the [pipeline passed](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines/702437095)
     and the `image:docs-single` job finished successfully, the Docker image
     is now uploaded to the registry.

### `Gem::FilePermissionError: You don't have write permissions for the /usr/local/bundle directory`

To build the Docker images, we use [Docker-in-Docker (dind)](https://hub.docker.com/_/docker/)
as defined in [`.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/6d4e30f1c14917cf895ee9250c29e0e18309796a/.gitlab-ci.yml#L529-533).

If the `image` and `services` images use different docker versions,
you are very likely to encounter an error like the following:

```plaintext
`/root` is not writable.
Bundler will use `/tmp/bundler20220122-1-5zons41' as your home directory temporarily.
Fetching gem metadata from https://rubygems.org/..........
Fetching rake 13.0.6
Installing rake 13.0.6
Gem::FilePermissionError: You don't have write permissions for the
/usr/local/bundle directory.
An error occurred while installing rake (13.0.6), and Bundler cannot continue.
```

This can also happen if you're using `docker:latest` instead of a stable version.

To fix the error, make sure the Docker images for `image` and `services` use
the same stable version. For example:

```yaml
image: docker:24.0.2
services:
  - docker:24.0.2-dind
```

If the error still persists, use a more recent `docker:` version
(search in [Docker Hub](https://hub.docker.com/_/docker/)).

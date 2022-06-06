# Monthly documentation releases

When a new GitLab version is released on the 22nd, we release version-specific published
documentation for the new version.

The tasks described in this document cover the preparation steps and the publication steps. The
preparation steps are completed on your local computer. The publication steps are completed in the
GitLab UI.

When you've completed the documentation release process:

- The [online published documentation](https://docs.gitlab.com) includes:
  - The three most recent minor releases of the current major version. For example 13.9, 13.8, and
    13.7.
  - The most recent minor releases of the last two major versions. For example 12.10, and 11.11.
- Documentation updates after the 22nd are for the next release. The versions dropdown
  should have the current milestone with `-pre` appended to it, for example `13.10-pre`.

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

- Complete the preparation steps between the 17th and the 20th of the month. **All** of the following steps
  must be completed successfully before proceeding with the publication steps:

  1. [Create a stable branch and Docker image](#create-stable-branch-and-docker-image-for-release) for
     the new version.
  1. [Create a release merge request](#create-release-merge-request) for the new version, which
     updates the version dropdown menu for the current documentation and adds the release to the
     Docker configuration. For example, the
     [release merge request for 13.9](https://gitlab.com/gitlab-org/gitlab-docs/-/merge_requests/1555).

     Try to create the MR close to the cutoff for `gitlab` project's stable branch for the release.
     If the `gitlab-docs` MR is too early or late, a mismatch between the `gitlab` project's
     documentation files and the `gitlab-docs` global navigation can cause failed MR pipelines that
     must be manually fixed. To check the status of the `gitlab` release, go to the `#releases`
     Slack channel and look for the `This is the candidate commit to be released on the 22nd.`
     message.

  1. [Update the three online versions](#update-dropdown-for-online-versions), so that they display the new release on their
     version dropdown menus.

- Complete the publication steps on the 22nd of the month, after the release post is live:

  [Merge the release merge requests and run the necessary Docker image builds](#merge-merge-requests-and-run-docker-image-builds).

  If the 22nd of the month falls on a weekend or public holiday, it's Ok to complete this last publication step on the next working day. 

## Create stable branch and Docker image for release

To create a stable branch of the `gitlab-docs` project and a Docker image for the release:

1. Make sure you're in the root path of the `gitlab-docs` repository.
1. Update your local clone:

   ```shell
   git stash -u
   git fetch origin && git rebase origin/main
   ```

1. Run the Rake task to create the single version. For example, to create the 15.0 release branch
   and perform other tasks:

   ```shell
   ./bin/rake "release:single[15.0]"
   ```

   A branch for the release is created, a new `15.0.Dockerfile` is created, and `.gitlab-ci.yml`
   has branches variables updated into a new branch. These files are automatically committed.

1. Push the newly created branch, but **don't create a merge request**.

   After you push, the `image:docs-single` job creates a new Docker image tagged with the name of
   the branch you created earlier.

   Confirm the Docker image has been created. Go to the `registry` environment at
   <https://gitlab.com/gitlab-org/gitlab-docs/-/environments/folders/registry> and confirm the image
   is listed. The Docker image may not be created if stable branches have not been created for all
   the related projects. If that occurs, continue with the docs release process because the
   Docker creation job will be run again later in the process.

For example, see [the 13.9 release pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines/260288747).

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
   git stash -u
   git fetch origin && git rebase origin/main
   ```

1. Create a branch `release-X-Y`. For example:

   ```shell
   git checkout main
   git checkout -b release-15-0
   ```

   Confirm the branch has been created. Go to <https://gitlab.com/gitlab-org/gitlab-docs/-/branches/active>
   and verify the branch is listed.

1. Edit `content/_data/versions.yaml` and update the lists of versions to reflect the new release:

   - Add the latest version to the `online:` section.
   - Move the oldest version in `online:` to the `offline:` section. There should now be three
     versions in `online:`.

1. Edit `latest.Dockerfile` by removing the oldest version, and then adding the newest version to the top of the list.

1. Commit and push to create the merge request. For example:

   ```shell
   git add content/_data/versions.yaml latest.Dockerfile
   git commit -m "Release 15.0"
   git push origin release-15-0
   ```

1. Create the merge request and choose the `Release` description
   template. Set the merge request to _Draft_ status and do not merge it yet.

## Update dropdown for online versions

To update `content/_data/versions.yaml` for all `online` and `previous_majors`
versions (stable branches `X.Y` of the `gitlab-docs` project):

1. Run the Rake task that creates the merge requests to update the dropdowns for the current major version. For
   example, for the 14.7 release:

   ```shell
   git checkout release-14-7
   ./bin/rake release:dropdowns
   ```

   For the 14.7 release, the task created [five merge requests](https://gitlab.com/gitlab-org/gitlab-docs/-/merge_requests?scope=all&state=all&label_name[]=release&milestone_title=14.7&search=update).

1. [Visit the merge requests page](https://gitlab.com/gitlab-org/gitlab-docs/-/merge_requests?label_name%5B%5D=release)
   to check that their pipelines pass. Set each merge request to _draft_ status and do not merge them yet.

## Merge merge requests and run Docker image builds

_Do this after the release post is live._

The merge requests for the dropdowns should now all be merged into their respective stable branches.

1. Check the [pipelines page](https://gitlab.com/gitlab-org/gitlab-docs/pipelines)
   and make sure the pipelines in all the MRs are green.
1. Merge all of the [dropdown merge requests](#update-dropdown-for-online-versions).
1. Merge the [release merge request](#create-release-merge-request).
1. Each merge triggers a new pipeline for each stable branch.
   Check the [pipelines page](https://gitlab.com/gitlab-org/gitlab-docs/pipelines) and wait
   for all the stable branch pipelines to complete.
1. Go to the [scheduled pipelines page](https://gitlab.com/gitlab-org/gitlab-docs/pipeline_schedules)
   and run the `Build docker images weekly` pipeline.
1. In the scheduled pipeline you just started, manually run the **image:docs-latest** job that builds the `:latest` Docker image.
1. When the pipeline is complete, run the `Build docs.gitlab.com every 4 hours` scheduled pipeline to deploy all new versions to the public documentation site.
   You don't need to run any jobs manually for this second pipeline.

## Post-deployment checklist

After the documentation is released, verify the documentation site has been deployed as expected.
Open site `docs.gitlab.com` in a browser and confirm both the latest version and the correct `pre-`
version are listed in the documentation version dropdown.

For example, if you released the 14.1 documentation, the first dropdown entry should be
`GitLab.com (14.2-pre)`, followed by `14.1`.

## Troubleshooting

### `Could not find remote branch` error

When you create the [stable branch](#create-stable-branch-and-docker-image-for-release)
or create the MRs to [update the dropdown](#update-dropdown-for-online-versions),
the pipeline fails with an error similar to the following:

```shell
warning: Could not find remote branch 5-3-stable to clone.
fatal: Remote branch 5-3-stable not found in upstream origin
```

This error occurs because the latest Charts stable branch hasn't been created yet.

This is fine! [Keep an eye on the Charts branches](https://gitlab.com/gitlab-org/charts/gitlab/-/branches)
and when the Charts branch is cut:

- If the error happens when you create the stable branch, go to the **Pipelines** page and run a new pipeline for your branch.
- If the error happens when you create the MRs to update the dropdown, return to your MR and run the pipeline again.

### image:docs-latest job fails with `GemNotFound` error

When you start the **Build docker images weekly** scheduled pipeline and
[run the **image:docs-latest** job](#merge-merge-requests-and-run-docker-image-builds),
the job fails with an error similar to the following:

```shell
bundler: failed to load command: rake (/usr/local/bundle/bin/rake)
Bundler::GemNotFound: Could not find <some gem>
```

This error can occur when there was a recent update to
dependencies in the [`Gemfile.lock`](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/Gemfile.lock)
file, but the dependencies are missing from
the latest [`gitlab-docs:bootstrap`](https://docs.gitlab.com/ee/development/documentation/site_architecture/deployment_process.html) image.

1. Start a new **Build docker images weekly** pipeline.
1. Run the **image:bootstrap** job. This job creates a new bootstrap image
   and adds it to the container registry.
1. After the **Build** and **Test** stages are complete, run the **image:docs-latest** job.

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
image: docker:20.10.8
services:
  - docker:20.10.8-dind
```

If the error still persists, use a more recent `docker:` version
(search in [Docker Hub](https://hub.docker.com/_/docker/)).

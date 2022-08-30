<!--
SET TITLE TO: docs.gitlab.com release XX.ZZ (month, YYYY)
-->

## Tasks for all releases

Documentation [for handling the docs release](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md) is available.

### Between the 17th and 20th of each month

1. [ ] Cross-link to the main MR for the release post: `<add link here>`
   ([Need help finding the MR?](https://gitlab.com/gitlab-com/www-gitlab-com/-/merge_requests?scope=all&state=opened&label_name%5B%5D=release%20post&label_name%5B%5D=blog%20post))
1. [ ] Monitor the `#releases` Slack channel. When the announcement
   `This is the candidate commit to be released on the 22nd` is made, it's time to begin.
1. [ ] [Create a stable branch and Docker image for release](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md#create-stable-branch-and-docker-image-for-release). Do not create a merge request, just push the stable branch.
   You can expect the `image:docs-single` job to fail initially because often not all stable branches are created yet. Some of the stable
   branches are created close to the 22nd, which will resolve most issues when you follow the rest of the steps.
1. [ ] [Create a docs.gitlab.com release merge request](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md#create-release-merge-request)
   which updates the version dropdown menu for all online versions, updates the archives list, and adds
   the release to the Docker configuration.
   - [ ] Mark as `Draft` and do not merge.

After the tasks above are complete, you don't need to do anything for a few days.

### On the 22nd, or the first business day after

After release post is live on the 22nd, or the next Monday morning if the release post happens on a weekend:

1. [ ] Verify that the [pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines?page=1&scope=all) for the stable branch
   has passed and created a [Docker image](https://gitlab.com/gitlab-org/gitlab-docs/container_registry/631635?orderBy=NAME&sort=desc&search[]=)
   tagged the release version. ([If it fails, how do I fix it?](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md#imagedocs-latest-job-fails-due-to-broken-links))
1. Deploy the versions:
   1. [ ] Go to the [scheduled pipelines page](https://gitlab.com/gitlab-org/gitlab-docs/-/pipeline_schedules)
      and run the `Build Docker images weekly` pipeline.
   1. [ ] In the scheduled pipeline you just started, cancel the pipeline, and manually run the `image:docs-latest`
      job that builds the `:latest` Docker image.
   1. [ ] When the job is complete, merge the docs release merge request.
1. [ ] After the deployment completes, open `docs.gitlab.com` in a browser. Confirm
   both the latest version and the correct pre-release version are listed in the documentation version dropdown.
1. [ ] Check all published versions of the docs to ensure they are visible and that their version menus have the latest versions.
1. [ ] In this issue, create separate _threads_ for the retrospective, and add items as they appear:
   - `## :+1: What went well this release?`
   - `## :-1: What didn’t go well this release?`
   - `## :chart_with_upwards_trend: What can we improve going forward?`
1. [ ] Mention `@gl-docsteam` in a comment and invite them to read and participate in the retro threads.

   ```markdown
   @gl-docsteam here's the docs release issue for XX.ZZ with some retro threads, per our [process](#on-the-22nd-or-the-first-business-day-after).
   ```

After the 22nd of each month:

1. [ ] Create a release issue for the
   [next TW](https://about.gitlab.com/handbook/engineering/ux/technical-writing/#regularly-scheduled-tasks)
   and assign it to them.
1. [ ] **Major releases only.** Update
   [OutdatedVersions.yml](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/.vale/gitlab/OutdatedVersions.yml)
   with the newly-outdated version.
1. [ ] Improve this checklist. Continue moving steps from
   [`releases.md`](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md)
   to here until the issue template is the single source of truth and the documentation provides extra information.

## Helpful links

- [Troubleshooting info](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md#troubleshooting)
- [List of upcoming assignees for overall release post](https://about.gitlab.com/handbook/marketing/blog/release-posts/managers/)
- [Internal docs for handling the docs release](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/releases.md)

/label ~"Technical Writing" ~"type::maintenance" ~"maintenance::refactor" ~"Category:Docs Site" ~release

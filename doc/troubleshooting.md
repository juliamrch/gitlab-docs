# Troubleshooting

The [`#docs-site-changes`](https://gitlab.slack.com/archives/C011D3TA610) Slack
channel gets notifications:

- When new MRs are opened, approved, and merged into `main`.
- For all failed pipelines in `main`.

Failed jobs are retried two more times if they fail (they run three times in total).
Before panicking about `main` being broken, navigate to the
[Pipelines page](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines) and see if
the latest pipeline is green.

- If yes, the failed pipeline can be ignored. In the `#docs-site-changes` channel,
  mark the failure notification with a ✅ to communicate that this failure doesn't
  need more research.
- If no, check the failed job to further troubleshoot the failure. If you're
  unsure of how to troubleshoot, post a question in `#tw-team`.

## Failed pipelines with no job specified

A pipeline failure reported in `#docs-site-changes` that doesn't specify a
particular job is usually caused because of an intermittent failure of the
`pages:deploy` job. Because these jobs are retried, the problem usual resolves
itself. To see if the problem is resolved:

1. Select the link to the pipeline given in Slack.
1. Confirm the latest run of `pages:deploy` was successful.

If the latest run of `pages:deploy` was not successful, continue troubleshooting.

## Failed jobs with Docker errors

Jobs that fail very quickly (the job fails before it reaches the **Getting source from Git repository** step)
with Docker errors are usually intermittent infrastructure problems. These problems usually
resolve themselves with retries. If repeated retries fail, continue troubleshooting.

For an example of a job with Docker errors, see: <https://gitlab.com/gitlab-org/gitlab/-/jobs/2834890543>.

## Failed jobs from upstream review apps

You can ignore any failures that come from an upstream review app.

The upstream projects (GitLab, Omnibus GitLab, GitLab Runner, Charts, Operator)
are configured so that you can manually run a docs review app for an open merge request.

The pipelines for review apps from upstream project MRs run for the `main` branch in the `gitlab-docs` project,
to ensure the review app uses the latest docs site code.
As a result, review app pipeline failures might get posted in the `#docs-site-changes` channel.

There are a few ways to tell whether a pipeline is from an upstream project:

- The **build** stage contains the `upstream_test_global_nav_links` job. Note the
  `upstream` in the name.
- The **test** stage contains only two jobs: `test_global_nav_links` and
  `untamper-my-lockfile`.
- The **deploy** stage contains the `review` job.

## Warning: `WARN: <icon name> is not a known icon in @gitlab-org/gitlab-svg`

When a new icon is added to the [`gitlab-svgs` library](https://gitlab.com/gitlab-org/gitlab-svgs)
and we use it immediately in the documentation, the `docs-lint links` job
in the upstream projects will include a warning like:

```plaintext
WARN: '<icon name>' is not a known icon in @gitlab-org/gitlab-svg. Contact the Technical Writing team for assistance.
```

This error happens when the `lint-html` image has an older version of `@gitlab/svgs`
which doesn't include the new icon.

To solve this, follow the template to build a
[new `lint-html` image](https://gitlab.com/gitlab-org/gitlab-docs/-/issues/new?issuable_template=html-lint-image-new-version&issue[title]=Upgrade%20the%20lint-html%20Docker%20image).

For more information, see issue [1639](https://gitlab.com/gitlab-org/gitlab-docs/-/issues/1639).

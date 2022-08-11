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

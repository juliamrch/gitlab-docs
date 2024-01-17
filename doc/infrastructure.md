# Docs site infrastructure

Use this guide to determine what to do in the event of infrastructure problems with the GitLab Docs website. Infrastructure issues will likely require enlisting help outside of the Technical Writing team.

## What is an infrastructure issue?

The term "infrastructure" refers to the services that host and deploy the website, not the website content or website-level code.

For example, the following problems could be infrastructure-related:

- Seeing a "500 Internal Server error" page
- Seeing a GitLab-branded "404 Not Found" page (not the regular Docs site [404 page](https://docs.gitlab.com/404))
- Seeing an error from your browser (e.g, "Too many redirects," or anything related to DNS lookups)

On the other hand, the following would most likely _not_ be infrastructure problems:

- Visual issues with the Docs website
- Missing or incorrect redirects
- Non-functioning components on the website (e.g, the global navigation fails to expand)

## Escalate an infrastructure issue

If you encounter an infrastructure problem, follow these steps:

1. Ask in the `#docs` Slack channel if others are experiencing the same problem.
1. Check the [status page](https://status.gitlab.com/) to see if there are open incidents related to GitLab Pages. If so, wait until these have been resolved before continuing to troubleshoot.
    - You can also check the [Incident Board](https://gitlab.com/gitlab-com/gl-infra/production/-/boards/1717012?&label_name%5B%5D=incident) to check the status of current incidents.
1. If the issue is reproducible by others and specific to the Docs site, you may need to declare an incident, which will request help from on-call Reliability Engineers. Follow [steps in the Handbook](https://about.gitlab.com/handbook/engineering/infrastructure/incident-management/#reporting-an-incident) to initiate this process.
    - When declaring an incident, you will need to set a [Severity Level](https://handbook.gitlab.com/handbook/engineering/infrastructure/incident-management/#severities).
      - If the Docs site is completely down, this is a `~severity::2`.
      - Intermittent availability issues would be a `~severity::3`.
      - Deployment issues would be a `~severity::4`.
    - As part of the incident response process, the [Communications Manager On-Call (CMOC)](https://handbook.gitlab.com/handbook/support/workflows/cmoc_workflows/) from GitLab Support may decide to update [status.gitlab.com](https://status.gitlab.com) to let customers know that we are working on resolving the issue.
1. Notify the Technical Writing team in Slack in `#tw-team` and `#docs`. Include a link to any relevant incident issues.

## Escalate a deployment problem

Deployments can be impacted by problems with the `gitlab-docs` pipeline, or issues with GitLab.com. This means they may be an infrastructure problem, but not always.

An occasional failed job is not reason for concern, as intermittent issues are not uncommon in CI environments, but repeated failures may require further troubleshooting.

If the site is repeatedly failing to deploy:

1. Check the [status page](https://status.gitlab.com/) to see if there are open incidents related to CI/CD, Git Operations, or the Container Registry. If any of these services are having issues, wait until these have been resolved before continuing to troubleshoot.

If there is not an open incident, GitLab team members can additionally follow these steps to troubleshoot and escalated the problem:

1. Try running the deploy job again. Maintainers can [deploy manually](https://docs.gitlab.com/ee/development/documentation/site_architecture/deployment_process.html#manually-deploy-to-production) outside of the regular hourly pipeline.
1. Request help in the `#docs` channel. Technical Writing team members with experience working on the pipeline may be able to diagnose the problem or at least determine if it's an infrastructure problem that should be escalated to Engineering.
1. Request help in the `#gitlab-pages` channel if errors look related to the GitLab Pages service.
1. If the problem persists, or if you are unable to get a response in `#gitlab-pages`, [declare an incident](https://about.gitlab.com/handbook/engineering/infrastructure/incident-management/#reporting-an-incident) to engage an on-call site reliability engineer.

### Review apps

Review apps are currently hosted on Google Cloud Platform, not GitLab Pages, and this configuration is managed by the [Production Engineering Foundations Team](https://handbook.gitlab.com/handbook/engineering/infrastructure/).

If you are experiencing issues with Docs review apps:

- GitLab team members can request help in the `#docs` Slack channel, or create an issue in the `gitlab-docs` project and ping `@axil` and `@sarahgerman`.
- If the issue seems to be related to infrastructure, GitLab team members can also request help in the `#infrastructure-lounge` Slack channel.
- Contributors can ping a [technical writer](https://handbook.gitlab.com/handbook/product/ux/technical-writing/#designated-technical-writers) in the merge request.

See [Documentation review apps](https://docs.gitlab.com/ee/development/documentation/review_apps.html) for more information.

## See also

- [Status page](https://status.gitlab.com)
- [Incident Management](https://about.gitlab.com/handbook/engineering/infrastructure/incident-management/)

# GitLab docs rake tasks

The GitLab Docs project has some raketasks that automate various things. You
can see the list of rake tasks with:

```shell
bundle exec rake -T
```

## Generate the feature flag tables

The [feature flag tables](https://docs.gitlab.com/ee/user/feature_flags.html) are generated
dynamically when GitLab Docs are published.

To generate these tables locally, generate `content/_data/feature_flags.yaml`:

```shell
bundle exec rake generate_feature_flags
```

Do this any time you want fresh data from your GitLab checkout.

Any time you rebuild the site using `nanoc`, the feature flags tables are populated with data.

## Clean up redirects

The `docs:clean_redirects` rake task automates the removal of the expired redirect files,
which is part of the monthly [scheduled TW tasks](https://about.gitlab.com/handbook/product/ux/technical-writing/#regularly-scheduled-tasks)
as seen in the "Local tasks" section of the [issue template](https://gitlab.com/gitlab-org/technical-writing/-/blob/main/.gitlab/issue_templates/tw-monthly-tasks.md):

1. Make sure you have `jq` installed. On macOS:
   - Use `brew list` and see if `jq` is in the list.
   - If it is not installed, run `brew install jq`.

1. Optional. Run the rake task locally in your `gitlab-docs` directory in a "dry run" mode
   that does not create any MRs:

   ```shell
   SKIP_MR=true bundle exec rake docs:clean_redirects
   ```

1. Run the rake task locally in your `gitlab-docs` directory. This command creates up to five
   merge requests:

   ```shell
   bundle exec rake docs:clean_redirects
   ```

The task:

1. Searches the doc files of each upstream product and:
   1. Checks the `remove_date` defined in the YAML front matter. If the
      `remove_date` is before the day you run the task, it removes the doc
      and updates `content/_data/redirects.yaml`.
   1. Creates a branch, commits the changes, and pushes the branch with
      various push options to automatically create the merge request.
1. When all the upstream products MRs have been created, it creates a branch
   in the `gitlab-docs` repository, adds the changed `content/_data/redirects.yaml`,
   and pushes the branch with various push options to automatically create the
   merge request.

Once all the MRs have been created, be sure to edit them to cross link between
them and the recurring tasks issue.

To omit the automatic merge request creation:

```shell
SKIP_MR=true bundle exec rake docs:clean_redirects
```

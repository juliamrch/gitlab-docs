# GitLab Docs rake tasks and scripts

The GitLab Docs project has some Rake tasks that automate various things. You
can see the list of rake tasks with:

```shell
bundle exec rake -T
```

## Clone the documentation repositories

> **Note:** This is similar to
> [`make clone-all-docs-projects`](setup.md#clone-all-documentation-repositories).
> The Rake task is primarily used when building the site in CI/CD.

The [`clone_repositories` rake task](../lib/tasks/build_site.rake) clones all the
[documentation repositories](architecture.md):

```shell
bundle exec rake clone_repositories
```

The cloned locations are defined in [`nanoc.yaml` under `data_sources`](../nanoc.yaml).

The task clones (with a depth of 1) either all the repositories or only one of them:

- **All repositories:** When the task is run with no evironment variables set,
  either locally or in a pipeline under `gitlab-docs`.
- **One repository:** When the task is run with some specific environment
  variables, usually when a review app is triggered in one of the
  [upstream projects](#usage-of-clone_repositories-in-an-upstream-review-app).

Available environment variables:

- `REMOVE_BEFORE_CLONE` or `CI`: if either of them is set (the value doesn't matter),
  the repository to be cloned is removed if it already exists. This is always
  set in a pipeline since `CI` is set to `true` by default, and it makes sure we're
  not reusing an old version of the docs in case we land on a runner that already
  has a docs build.
- `BRANCH_<slug>`: if you want to clone an upstream branch
  [other than the default](#clone-an-upstream-branch-other-than-the-default).

### Clone an upstream branch other than the default

The
[`clone_repositories` task](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/fd64306b4ba4efd4081ac96e7cf69756fef2ce2f/lib/tasks/build_site.rake#L10)
clones the
[default branch](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/fd64306b4ba4efd4081ac96e7cf69756fef2ce2f/lib/tasks/task_helpers.rb#L41)
of an upstream project if the `BRANCH_<slug>` variable is not set.

If you want to use another branch, you can use the `BRANCH_<slug>` environment
variable for the following products:

- `BRANCH_EE` for `gitlab-org/gitlab`
- `BRANCH_OMNIBUS` for `gitlab-org/omnibus-gitlab`
- `BRANCH_RUNNER` for `gitlab-org/gitlab-runner`
- `BRANCH_CHARTS` for `gitlab-org/charts/gitlab`
- `BRANCH_OPERATOR` for `gitlab-org/cloud-native/gitlab-operator`

You can use those variables either locally or in a merge request:

- The most common scenario is when you'd like to deploy a `gitlab-docs`
  review app using an upstream branch that contains changes pertinent to that
  `gitlab-docs` merge request:

  1. In a `gitlab-docs` merge request, edit the `variables` section of
     [`.gitlab-ci.yml`](../.gitlab-ci.yml), adding the `BRANCH_<slug>` variable
     you want to pull the respective upstream branch for.
  1. When you verify the merge request works the way you want, restore
     `.gitlab-ci.yml` the way it was.

- You can also use it locally by setting the variable before running the Rake task,
  for example:

  ```shell
  BRANCH_EE=update-tier-badges bundle exec rake clone_repositories
  ```

  The above example fetches the default branches for all the upstream projects
  except for `gitlab-org/gitlab`, which is set to `update-tier-badges`.

### Usage of `clone_repositories` in an upstream review app

When you trigger a review app from an upstream project, only that project
is cloned and built.

The following process describes how this works:

1. You trigger a [review app](https://docs.gitlab.com/ee/development/documentation/review_apps.html)
   in an upstream project.
1. The following variables are [set and passed](https://gitlab.com/gitlab-org/gitlab/-/blob/53233de16cafa6544ebe7bfbe41fd65e95645c8e/scripts/trigger-build.rb#L239-337)
   on the `gitlab-docs` pipeline:
   - `BRANCH_<slug>` is set to the upstream project's branch name, where
     `<slug>` is one of `ee`, `omnibus`, `runner`, `charts`, `operator`. With this
     variable set up, when the docs site is built, it fetches the
     [respective upstream branch](#clone-an-upstream-branch-other-than-the-default).
   - `CI_PIPELINE_SOURCE` is set to `trigger`.
1. A minimal pipeline is run in `gitlab-docs` with two jobs:
   - `compile_upstream_review_app`: builds the site by using the `clone_repositories`
     Rake task with the environment variables above:
     1. Iterate over the five products.
     1. If `CI_PIPELINE_SOURCE` is set to `trigger`, **and** the `BRANCH_<project>` exists,
        fetch the repository. Otherwise, skip it.
   - `review`: deploys the artifacts (compiled site) from the previous job in a GCP bucket.

## Generate the feature flag tables

The [feature flag tables](https://docs.gitlab.com/ee/user/feature_flags.html) are generated
dynamically when GitLab Docs are published.

To generate these tables locally, generate `content/_data/feature_flags.yaml`:

```shell
bundle exec rake generate_feature_flags
```

Do this any time you want fresh data from your GitLab checkout.

Any time you rebuild the site using `nanoc`, the feature flags tables are populated with data.

When this Rake task is run as part of an upstream review app,
`TOP_UPSTREAM_SOURCE_PROJECT` is set to the upstream project's path, and it's skipped if
it's not `'gitlab-org/gitlab'`. This is used in conjuction with
[`clone_repositories`](#usage-of-clone_repositories-in-an-upstream-review-app).

## Clean up redirects

The `docs:clean_redirects` rake task automates the removal of the expired redirect files,
which is part of the monthly [scheduled TW tasks](https://about.gitlab.com/handbook/product/ux/technical-writing/#regularly-scheduled-tasks)
as seen in the "Local tasks" section of the [issue template](https://gitlab.com/gitlab-org/technical-writing/-/blob/main/.gitlab/issue_templates/tw-monthly-tasks.md):

1. Make sure you have `jq` installed. On macOS:
   - Use `brew list` and see if `jq` is in the list.
   - If it is not installed, run `brew install jq`.

1. Run the rake task locally in your `gitlab-docs` directory in a "dry run" mode that does not make any local changes or
   create merge requests:

   ```shell
   DRY_RUN=true bundle exec rake docs:clean_redirects
   ```

   Check that this runs succesfully before continuing. If it doesn't run successfully, correct any errors before
   continuing.

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

## Find pages that are not included in the global navigation

Run this command to check for pages that are missing from the global navigation:

```shell
make check-pages-not-in-nav
```

This invokes a [Node.js script](../scripts/pages_not_in_nav.js) that outputs JSON containing matching page URL paths and the associated Section and Group to the console.

Before running the script, you may want to run `make update-all-docs-projects` to pull down the latest content from each source project.

You can use `jq` on the command line to extract specific fields. For example, to return a list of only URLs:

```shell
make check-pages-not-in-nav | jq '.[] | .url'
```

The script intentionally omits:

- Sections referenced in the ["Pages you don’t need to add"](https://docs.gitlab.com/ee/development/documentation/site_architecture/global_nav.html#pages-you-dont-need-to-add) section of our docs.
- Redirects.
- Markdown files that are not compiled to HTML pages (see the `ignore` paths in Nanoc's [Rules](../Rules) file).

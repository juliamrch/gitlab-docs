# Testing the GitLab Docs site

Tests for the GitLab Docs site include tests for code and tests for links in content. For more information, see
[Documentation testing](https://docs.gitlab.com/ee/development/documentation/testing/).

Tests are run in `gitlab-docs` [CI/CD pipeline](https://gitlab.com/gitlab-org/gitlab-docs/-/pipelines), which is
configured in the project's [`.gitlab-ci.yml`](../.gitlab-ci.yml) file.

## Code tests

These code tests are included in the project:

| Test target   | Tool         | Make target          | Purpose                                    |
|:--------------|:-------------|:---------------------|:-------------------------------------------|
| CSS           | Stylelint    | `stylelint-tests`    | Code quality                               |
| Dockerfiles   | Hadolint     | `hadolint-tests`     | Syntax checks                              |
| JavaScript    | ESLint       | `eslint-tests`       | Syntax checks                              |
| JavaScript    | Prettier     | `prettier-tests`     | Code formatting                            |
| Markdown      | markdownlint | `markdownlint-tests` | Documentation formatting and syntax checks |
| Ruby          | RSpec        | `rspec-tests`        | Unit tests                                 |
| Shell scripts | ShellCheck   | `shellcheck-tests`   | Syntax checks                              |
| Vue           | Jest         | `jest-tests`         | Unit tests                                 |
| YAML          | yamllint     | `yamllint-tests`     | Syntax checks                              |

### Run code tests locally

To run all tests:

```shell
make test
```

You can also run tests individually by specifying the Make target. For example, to run RSpec tests only:

```shell
make rspec-tests
```

### Install Lefthook

If you want to run the tests before pushing changes, use [Lefthook](https://github.com/evilmartians/lefthook#readme).
To install Lefthook, run:

```shell
lefthook install
```

Tests are run whenever you run `git push`.

Lefthook is configured in [`lefthook.yml`](../lefthook.yml).

## Link tests

You can use `gitlab-docs` to test links in content. These tests don't test `gitlab-docs`, but the content in the
projects that comprise the published GitLab Docs site.

### Run link tests locally

To test links between content pages, run:

```shell
make internal-links-check
```

To test anchor links, run:

```shell
make internal-anchors-check
```

To test both links between content pages and anchor links, run:

```shell
make internal-links-and-anchors-check
```

To test external links, run:

```shell
make external-links-check
```

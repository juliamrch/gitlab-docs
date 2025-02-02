# GitLab docs site maintenance

Some of the issues that the GitLab technical writing team handles to maintain
<https://docs.gitlab.com> include:

- The [deployment process](#deployment-process).
- Temporary [event or survey banners](#survey-banner).
- [CSP headers](#csp-header).

## Deployment process

We use [GitLab Pages](https://about.gitlab.com/features/pages/) to build and
host this website.

The site is built and deployed automatically in GitLab CI/CD jobs.
See [`.gitlab-ci.yml`](../.gitlab-ci.yml)
for the current configuration. The project has [scheduled pipelines](https://docs.gitlab.com/ee/user/project/pipelines/schedules.html)
that build and deploy the site every hour.

## Survey banner

In case there's a survey that needs to reach a big audience, the docs site has
the ability to host a banner for that purpose. When it is enabled, it's shown
at the top of every page of the docs site.

To publish a survey, edit [`banner.yaml`](/content/_data/banner.yaml) and:

1. Set `show_banner` to `true`.
1. Under `description`, add what information you want to appear in the banner.
   Markdown is supported.

To unpublish a survey, edit [`banner.yaml`](/content/_data/banner.yaml) and
set `show_banner` to `false`.

## CSP header

The GitLab docs site uses a [Content Security Policy (CSP) header](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
as an added layer of security that helps to detect and mitigate certain types of
attacks, including Cross Site Scripting (XSS) and data injection attacks.
Although it is a static site, and the potential for injection of scripts is very
low, there are customer concerns around not having this header applied.

It's enabled by default on <https://docs.gitlab.com>, but if you want to build the
site on your own and disable the inclusion of the CSP header, you can do so with
the `DISABLE_CSP` environment variable:

```shell
DISABLE_CSP=1 make compile
```

### Add or update domains in the CSP header

The CSP header and the allowed domains can be found in the [`csp.html`](../layouts/csp.html)
layout. Every time a new font or Javascript file is added, or maybe updated in
case of a versioned file, you need to update the `csp.html` layout, otherwise
it can cause the site to misbehave and be broken.

### No inline scripts allowed

To avoid allowing `'unsafe-line'` in the CSP, we cannot use any inline scripts.
For example, this is prohibited:

```html
<script>alert('Hello world');</script>
```

Instead, JavaScript should be extracted to its own files. See [Add a new bundle](development.md#add-a-new-bundle) for more information.

### Test the CSP header for conformity

To test that the CSP header works as expected, you can visit
<https://cspvalidator.org/> and paste the URL that you want tested.

## Project tokens

The `gitlab-docs` project uses several project access tokens.

### Review apps

The `gitlab-docs` project has two access tokens used for review apps. If you change
or delete these tokens, review apps will stop working:

- `DOCS_TRIGGER_TOKEN` is a [trigger token](https://docs.gitlab.com/ee/ci/triggers/index.html#trigger-token).
  This token is used by other projects to authenticate with the `gitlab-docs` project
  and trigger a review app deployment pipeline.
- `DOCS_PROJECT_API_TOKEN` is a [project access token](https://docs.gitlab.com/ee/user/project/settings/project_access_tokens.html).
  This token is used by other projects to poll the review app deployment pipeline
  and determine if the pipeline has completed successfully.

All projects that have documentation review apps use these tokens when running the
[`trigger-build` script](https://gitlab.com/gitlab-org/gitlab/-/blob/b09be454102f4d53ec7963aef8a625daf8ef6acc/scripts/trigger-build#L207)
to deploy a review app.

### Danger bot

The `gitlab-docs` project has the `DANGER_GITLAB_API_TOKEN` project access token set, which is set as a CI/CD variable
for the <https://gitlab.com/gitlab-org/components/danger-review> component. This component adds comments to merge
requests based on Danger configuration.

If not set, Danger comments aren't added to merge requests.

## Redirects

The GitLab Docs site has two kinds of redirects.

If both of the redirects are present, the [HTML meta tag redirects](#html-meta-tag-redirects)
override the [Pages redirects](https://docs.gitlab.com/ee/user/project/pages/redirects.html#files-override-redirects).

### HTML meta tag redirects

If a page has the `redirect_to` metadata in the YAML front matter, it
redirects to the path defined in the metadata:

1. When Nanoc builds the site, it makes some changes in the [`preprocess`](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/4fc73c9a5f1652cc2e0b284bfe1e937887a37183/Rules#L6)
   step. For the redirects, it [checks for a `redirect_to` item identifier](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/4fc73c9a5f1652cc2e0b284bfe1e937887a37183/Rules#L21-28)
   (the YAML metadata) and changes the extension from `.md` to `.html`.
1. Next, it compiles all the markdown files into HTML. In this step, it first checks
   [if the `redirect_to` metadata is present](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/4fc73c9a5f1652cc2e0b284bfe1e937887a37183/Rules#L61),
   and if it is, the [redirect layout is used](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/4fc73c9a5f1652cc2e0b284bfe1e937887a37183/Rules#L105).
1. The [redirect layout](../layouts/redirect.html)
   is a simple HTML page that essentially does two things:
   - It uses an [`http-equiv` meta tag](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/4fc73c9a5f1652cc2e0b284bfe1e937887a37183/layouts/redirect.html#L8)
     with the URL set to the one defined in the `redirect_to` metadata of the
     markdown file:

     ```html
     <meta http-equiv="refresh" content="0; url=<%= @item[:redirect_to] %>">
     ```

   - If for some reason this doesn't work,
     [there's an additional URL](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/4fc73c9a5f1652cc2e0b284bfe1e937887a37183/layouts/redirect.html#L24-26)
     that explicitly points to the redirect URL that the user can manually click
     and get redirected:

     ```html
     <a href="<%= @item[:redirect_to] %>">Click here if you are not redirected.</a>
     ```

### Pages redirects

The GitLab Docs site is deployed in GitLab Pages and can leverage some of its
features. We can enable server-side redirects by using a
[`_redirects` file](https://docs.gitlab.com/ee/user/project/pages/redirects.html)
that contains the redirect rules.

We have a lot of redirects, so maintaining this plaintext file is cumbersome.
Instead, we use a YAML file which is then converted into the `_redirects` file:

1. The [`redirects.yaml` file](../content/_data/redirects.yaml)
   contains the redirect entries for the Docs site:

   | Entry          | Required               | Description |
   | -------------- | ---------------------- | ----------- |
   | `from`         | **{check-circle}** Yes | The old path of the page to redirect from. |
   | `to`           | **{check-circle}** Yes | The new path of the page to redirect to.   |
   | `remove_date`  | **{dotted-circle}** No | Not used by any code, shows when to remove entries from `redirects.yaml`. |

   These entries can be added manually, or by running the [clean up redirects Rake task](raketasks.md#clean-up-redirects) once a month.

1. Every time the site is built in the pipeline, the [redirects Rake task executes](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/4fc73c9a5f1652cc2e0b284bfe1e937887a37183/.gitlab-ci.yml#L194-195).
1. The [Rake task creates `public/_redirects`](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/4fc73c9a5f1652cc2e0b284bfe1e937887a37183/Rakefile#L217-231) by parsing `redirects.yaml`.
1. After Pages deploys the site, the `_redirects` file is at <https://docs.gitlab.com/_redirects>,
   and the redirects should be working.

## Regenerate tokens

The `gitlab-docs` project has several tokens used to authenticate with the API from
CI/CD pipelines. These tokens are stored in each project's CI/CD settings as
[CI/CD variables](https://docs.gitlab.com/ee/ci/variables/#add-a-cicd-variable-to-a-project):

- [`DOCS_PROJECT_API_TOKEN` and `DOCS_TRIGGER_TOKEN`](#project-tokens): Used by `gitlab`, `gitlab-runner`,
  `omnibus-gitlab`, `charts`, and `gitlab-operator` to create docs review apps.
- `DELETE_ENVIRONMENTS_TOKEN`: Used by `gitlab-docs` to
  [delete stale review app environments](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/452c30caebd9db6604d34f1fd04ce19c38ff2273/.gitlab/ci/build-and-deploy.gitlab-ci.yml#L155-L169).
- `DANGER_GITLAB_API_TOKEN`: Used by `gitlab-docs` to generate Danger bot comments in merge requests.

In the event of a security issue, it might be necessary to immediately secure the project
by regenerating the tokens, sometimes called "rotating" the tokens. You must be a
maintainer in the relevant projects to rotate the tokens. It is safe to immediately revoke the current tokens,
as they are only used for review apps or project maintenance.

In all cases, do not change any other settings for the CI/CD variables. They must remain
masked, but not protected. Additionally, do not save the token values anywhere else.

### Regenerate `DOCS_PROJECT_API_TOKEN`

To regenerate `DOCS_PROJECT_API_TOKEN`:

1. In `gitlab-docs`, go to **Settings > Access Tokens**.
1. In **Active project access tokens**, find the entry for `DOCS_PROJECT_API_TOKEN` and
   select **Revoke**.
1. Select **Add new token**, and fill in the following values:
   - **Token name**: `DOCS_PROJECT_API_TOKEN`.
   - **Expiration date**: None.
   - **Select a role**: `Developer`.
   - **Select scopes**: `api`.
1. Select **Create project access token**.
1. After the token is created, go to **Your new project access token** at the top
   and copy the token value. It should start with `glpat-`.
1. In `gitlab`, `gitlab-runner`, `omnibus-gitlab`, `charts`, and `gitlab-operator`, go to the
   [CI/CD variables settings](https://docs.gitlab.com/ee/ci/variables/#add-a-cicd-variable-to-a-project),
   expand **Variables**, select **Edit** for the `DOCS_PROJECT_API_TOKEN` CI/CD variable, and update the
   **Value** field with the new token.

### Rengenerate `DOCS_TRIGGER_TOKEN`

To regenerate `DOCS_TRIGGER_TOKEN`:

1. In `gitlab-docs`, go to **Settings > CI/CD** and expand **Pipeline trigger tokens**.
1. In the token table, find the entry for `DOCS_TRIGGER_TOKEN` and select **Revoke** (delete icon).
1. Select **Add new token**. Under **Description**, fill in `DOCS_TRIGGER_TOKEN`.
1. Select **Create pipeline trigger token**.
1. After the token is created, copy the token value from the table.
1. In `gitlab`, `gitlab-runner`, `omnibus-gitlab`, and `charts`, go to the
   [CI/CD variables settings](https://docs.gitlab.com/ee/ci/variables/#add-a-cicd-variable-to-a-project),
   expand **Variables**, select **Edit** for the `DOCS_TRIGGER_TOKEN` CI/CD variable, and update the
   **Value** field with the new token.

### Regenerate `DELETE_ENVIRONMENTS_TOKEN`

To regenerate `DELETE_ENVIRONMENTS_TOKEN`, follow the steps for rotating the `DOCS_PROJECT_API_TOKEN`, except use
`DELETE_ENVIRONMENTS_TOKEN` as the token name and update the CI/CD variable in the `gitlab-docs` project only.

### Regenerate `DANGER_GITLAB_API_TOKEN`

To regenerate `DANGER_GITLAB_API_TOKEN`:

1. In `gitlab-docs`, go to **Settings > Access Tokens**.
1. In **Active project access tokens**, find the entry for `DANGER_GITLAB_API_TOKEN` and
   select **Revoke**.
1. Select **Add new token**, and fill in the following values:
   - **Token name**: `DANGER_GITLAB_API_TOKEN`.
   - **Expiration date**: End of the year.
   - **Select a role**: `Developer`.
   - **Select scopes**: `api`.
   - **Description** : `DANGER_GITLAB_API_TOKEN`.
1. Select **Create project access token**.
1. After the token is created, go to **Your new project access token** at the top
   and copy the token value. It should start with `glpat-`.
1. In `gitlab-docs`, go to the [CI/CD variables settings](https://docs.gitlab.com/ee/ci/variables/#add-a-cicd-variable-to-a-project),
   expand **Variables**, select **Edit** for the `DANGER_GITLAB_API_TOKEN` CI/CD variable, and update the
   **Value** field with the new token.

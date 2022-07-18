# GitLab docs site maintenance

Some of the issues that the GitLab technical writing team handles to maintain
<https://docs.gitlab.com> include:

- The [deployment process](#deployment-process).
- [Algolia search](docsearch.md).
- Temporary [event or survey banners](#survey-banner).
- [CSP headers](#csp-header).

## Deployment process

We use [GitLab Pages](https://about.gitlab.com/features/pages/) to build and
host this website.

The site is built and deployed automatically in GitLab CI/CD jobs.
See [`.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/.gitlab-ci.yml)
for the current configuration. The project has [scheduled pipelines](https://docs.gitlab.com/ee/user/project/pipelines/schedules.html)
that build and deploy the site once every four hours.

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
DISABLE_CSP=1 bundle exec nanoc compile
```

### Add or update domains in the CSP header

The CSP header and the allowed domains can be found in the [`csp.html`](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/layouts/csp.html)
layout. Every time a new font or Javascript file is added, or maybe updated in
case of a versioned file, you need to update the `csp.html` layout, otherwise
it can cause the site to misbehave and be broken.

### No inline scripts allowed

To avoid allowing `'unsafe-line'` in the CSP, we cannot use any inline scripts.
For example, this is prohibited:

```html
<script>
$(function () {
  $('[data-toggle="popover"]').popover();
  $('.popover-dismiss').popover({
    trigger: 'focus'
  })
})
</script>
```

Instead, this should be extracted to its own files in the
[`/content/assets/javascripts/`](https://gitlab.com/gitlab-org/gitlab-docs/-/tree/main/content/assets/javascripts) directory,
and then be included in the HTML file that you want. The example above lives
under `/content/assets/javascripts/toggle_popover.js`, and you would call
it with:

```html
<script src="<%= @items['/assets/javascripts/toggle_popover.*'].path %>"></script>
```

### Test the CSP header for conformity

To test that the CSP header works as expected, you can visit
<https://cspvalidator.org/> and paste the URL that you want tested.

## Project tokens

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
1. The [redirect layout](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/layouts/redirect.html)
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

1. The [`redirects.yaml` file](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/content/_data/redirects.yaml)
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

## Review apps

The review apps server is hosted in GCP using the [sandbox](https://about.gitlab.com/handbook/infrastructure-standards/realms/sandbox/)
service provided by GitLab's infrastructure team. It is running Debian 11, and
it has 100GB of space.

The current owners of the GCP project are:

- Amy
- Axil
- Evan
- Marcel
- Marcin

If you need access, ask one of the above people to [add you to the owners](https://console.cloud.google.com/iam-admin/iam?project=axil-635e068f).

### Delete old review apps when there is not enough disk space

Each review app takes about 2.5GB of disk space.
Sometimes the review app server is full and there is no more disk space.
A cron job to remove review apps older than 14 days runs hourly,
but the disk space still occasionally fills up.

To manually free up more space, an owner of the GCP project can:

1. Navigate to the [GCP VM daashboard](https://console.cloud.google.com/compute/instances?project=axil-635e068f).
1. Select the SSH button to connect to the VM through your browaser.
1. Run the `clean-pages` script by providing it the number of days:

   ```shell
   sudo -u gitlab-runner /home/gitlab-runner/clean-pages 10
   ```

There's an issue to [migrate from the DigitalOcean server to GCP buckets](https://gitlab.com/gitlab-org/gitlab-docs/-/issues/735)),
which should solve the disk space problem.

See [this issue](https://gitlab.com/gitlab-org/gitlab-docs/-/issues/1152) for
more information.

### Resize review apps disk space

If the disk space is still running low, you can resize it:

1. Go to the [disk page](https://console.cloud.google.com/compute/disksDetail/zones/us-central1-a/disks/docs-review-apps?project=axil-635e068f)
1. Select **Edit**.
1. Fill in the new size in GB.
1. Select **Save**.
1. Reboot the VM.

See the [official GCP documentation](https://cloud.google.com/compute/docs/disks/resize-persistent-disk).

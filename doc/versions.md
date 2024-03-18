# Versioning

A new release of the Docs website is cut with each release of the GitLab product. Most of the site behaves the same way regardless of version, however there are a few features that are version-aware:

- Search
- Archived version banner
- Versions dropdown

See the table below for expected behavior:

| Version | Versions dropdown menu | Archived version banner | Search |
| -------- | ----- | ------- | ------|
| Pre-release | Shows the same options as docs.gitlab.com. Local links will not work; this is expected since you do not have all the versions available locally. | No banner | Google, non-prefixed result URLs |
| Stable | Shows the same options as docs.gitlab.com. Local links will not work; this is expected since you do not have all the versions available locally. | No banner | Google, non-prefixed result URLs (1) |
| Recent (last two minors before stable) | Shows the same options as docs.gitlab.com. Local links will not work; this is expected since you do not have all the versions available locally. | Banner (interior pages only) | Google, non-prefixed result URLs (1) |
| Archive | Shows only the active version and a link back to docs.gitlab.com/archives  | Banner (interior pages only) | Lunr with prefixed URLs |
| Offline archive | Shows only the active version and a link back to docs.gitlab.com/archives | No banner | Lunr with prefixed URLs |

1. There is an [open issue](https://gitlab.com/gitlab-org/gitlab-docs/-/issues/1674) to adjust this behavior.

## Environments for older releases

The pre-release version of the site is built from the `main` branch of this project and is available online at `docs.gitlab.com`.

Released versions need to run in three different places:

- `docs.gitlab.com/$VERSION` (e.g, docs.gitlab.com/16.7)
- `archives.docs.gitlab.com/$VERSION`
- a [self-hosted](https://docs.gitlab.com/ee/administration/docs_self_host.html) environment, which may be running offline, but must have a URL in the format of `example.com/$VERSION`

When working on version-aware features, you will need to consider these different environments and possibly test your work in multiple ways.

### Testing different versions

#### Test an archived release

1. Set yourself an environment variable with the desired version. For example:

   ```shell
   export VER="16.9"
   ```

1. Create a "release" version (this runs the same steps as we do through [single.Dockerfile](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/dockerfiles/single.Dockerfile?ref_type=heads)):

   ```shell
   ./scripts/normalize-links.sh public $VER && mkdir $VER && scripts/minify-assets.sh $VER/ public/ && mkdir dest && mv $VER dest/
   ```

1. Move this into the public directory so we can browse it locally:

   ```shell
   mv dest/$VER public
   ```

1. Run the local server:

   ```shell
   bundle exec nanoc view
   ```

1. Browse the site at `http://localhost:3000/16.9/`.

To test that this will work offline, turn off your Internet connection and browse around.

#### Test a Docker build

See [release docs](./releases.md#optional-test-locally) for steps to build and run a Docker image.

## Versioning logic

- **Backend:** The version of the site is set at build time from the `CI_COMMIT_REF_NAME` environment variable and is set in a metatag on the default template. On CI, this is the branch name.
  
  To manipulate this for testing locally, pass the `CI_COMMIT_REF_NAME` variable to the compile command, for example:

  ```shell
  CI_COMMIT_REF_NAME=16.9 make compile
  ```

   Remember that detecting the version from the backend does not allow you to determine the version relative to current, or anything else that changes over time. These values are captured at build time and not updated beyond that.

- **Frontend:** Frontend features can fetch up-to-date version context from the versions.json file at `docs.gitlab.com/versions.json`. While this can be used to determine an instance's status (pre-release, stable, etc.), remember that this (or any other `fetch` request) cannot be used in an offline environment.

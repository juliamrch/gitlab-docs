# GitLab docs site development

## Linking to source files

A helper called [`edit_on_gitlab`](../lib/helpers/edit_on_gitlab.rb) can be used
to link to a page's source file. We can link to both the simple editor and the
web IDE. Here's how you can use it in a Nanoc layout:

- Default editor:
  `<a href="<%= edit_on_gitlab(@item, editor: :simple) %>">Simple editor</a>`
- Web IDE: `<a href="<%= edit_on_gitlab(@item, editor: :webide) %>">Web IDE</a>`

If you don't specify `editor:`, the simple one is used by default.

## Using YAML data files

The easiest way to achieve something similar to
[Jekyll's data files](https://jekyllrb.com/docs/datafiles/) in Nanoc is by
using the [`@items`](https://nanoc.ws/doc/reference/variables/#items-and-layouts)
variable.

The data file must be placed inside the `content/` directory and then it can
be referenced in an ERB template.

Suppose we have the `content/_data/versions.yaml` file with the content:

```yaml
versions:
- 10.6
- 10.5
- 10.4
```

We can then loop over the `versions` array with something like:

```erb
<% @items['/_data/versions.yaml'][:versions].each do | version | %>

<h3><%= version %></h3>

<% end &>
```

Note that the data file must have the `yaml` extension (not `yml`) and that
we reference the array with a symbol (`:versions`).

## JavaScript

[Rollup](https://rollupjs.org/) is used on this project to bundle JavaScript into modules. See [rollup.config.js](../rollup.config.js) for configuration details.

New JavaScript that uses ES modules or imports should be added to the [content/frontend/](https://gitlab.com/gitlab-org/gitlab-docs/-/tree/main/content/frontend) directory. Vue components are all located here.

JavaScript that does not use ES modules, such as third-party analytics scripts, is located in [`content/assets/javascripts/`](https://gitlab.com/gitlab-org/gitlab-docs/-/tree/main/content/assets/javascripts/content/assets/javascripts). Code added here is not processed by Rollup.

### Development using watch mode

Watch mode recompiles assests as the files are changed on disk. This is useful for local development.

Start Rollup in watch mode:

```shell
yarn watch:js
```

Start Sass in watch mode:

```shell
yarn watch:css
```

### Add a new bundle

When adding a new bundle, the layout name (`html`) and bundle name (`js`) should
match to make it easier to find:

1. Add the new bundle to `content/frontend/<bundle-name>/<bundle-name>.js`.
1. Import the bundle in the HTML file `layouts/<bundle-name>.html`:

   ```html
   <script src="<%= @items['/frontend/<bundle-name>/<bundle-name>.*'].path %>"></script>
   ```

You should replace `<bundle-name>` with whatever you'd like to call your
bundle.

Nanoc then builds and renders those links correctly according with what's
defined in [`Rules`](../Rules).

## Adding query strings to CTAs headed to about.gitlab.com/pricing

We've created [a Sisense dashboard that can only be seen by full-time team members](https://app.periscopedata.com/app/gitlab/950797/GitLab.com-SaaS-trials---no-SAFE-data)
to track the number of SaaS free trials that start from a documentation page.

If you would like to track that information, add the following parameters to the URL:

- `glm_source` is `docs.gitlab.com`
- `glm_content` set to anything that ends with `-docs`

### Example

`https://about.gitlab.com/pricing?=glm_source=docs.gitlab.com&glm_content=name-of-item-docs`

## Run a fully-versioned Docs site locally

You can run the following bash script to fetch all the versions that appear in
the dropdown and have a fully-versioned site like the one in production.

Prerequisites:

- You must have Docker or another compatible container runtime installed.
- For Linux users, to run the `docker` CLI command as a non-root user,
  add your user to the `docker` user group, re-login, and restart
  `docker.service`.

Edit the `versions` array to match that of the dropdown:

```shell
#!/bin/bash
versions=( 15.0 14.10 14.9 13.12 )
for i in "${versions[@]}"
do
  docker create -it --name gitlab-docs-$i registry.gitlab.com/gitlab-org/gitlab-docs:$i
  docker cp gitlab-docs-$i:/usr/share/nginx/html/$i public/
  docker rm -f gitlab-docs-$i
done
```

### MacOS Docker considerations

Due to licensing restrictions, consider an alternative to Docker Desktop. There are several suggestions in [the handbook](https://handbook.gitlab.com/handbook/tools-and-tips/mac/#docker-desktop).

Technical Writing team members have had success using Colima. You will likely need to increase the amount of memory and disk space available for Colima. You can do this by modifying the Colima config file (`colima start --edit`):

```sh
# Number of CPUs to be allocated to the virtual machine.
# Default: 2
cpu: 8

# Size of the disk in GiB to be allocated to the virtual machine.
# NOTE: changing this has no effect after the virtual machine has been created.
# Default: 60
disk: 120

# Size of the memory in GiB to be allocated to the virtual machine.
# Default: 2
memory: 16
```

#### Troubleshooting Docker errors

##### `make: *** [Makefile:248: ArrayType.o] Segmentation fault (core dumped)` when building the image

Segfaults can occur when the environment runs out of resources. This can happen when building Ruby gems. Try increasing resources for Docker, and/or clearing up disk space with `docker system prune -af` and `docker system prune --volumes`.

##### `[emerg] 21#21: io_setup() failed (38: Function not implemented)` when running Nginx

This can be safely ignored. This comes up when running an image built on CI on your Mac and is due to hardware differences between the Linux and Mac environments.

##### `WARNING: The requested image's platform (linux/amd64) does not match the detected host platform`

This can be safely ignored, same reasons as above.

#### `http://0.0.0.0:4000` is blocked (Chrome) or invalid (Safari) or does not redirect (Firefox)

You need to use an address like `http://127.0.0.0.1:4000/16.8/` to view a Docker version locally. The trailing slash is required. Linux will redirect from `http://0.0.0.0:4000`, but MacOS does not and will show errors in the browser.

## Add a new product

NOTE:
We encourage you to create an issue and connect with the Technical Writing team before you add a new product to the documentation site, as there may be planning information that the team can help with, including integrating any new content into the site's global navigation menu.

To add an additional set of product documentation to <https://docs.gitlab.com> from a separate GitLab repository (beyond any product documentation already added to the site):

1. Clone the repository at the same root level as the `gitlab-docs` repository:

   ```shell
   git clone https://gitlab.com/<repo>.git <product_name>
   ```

1. Edit [`nanoc.yaml`](../nanoc.yaml) and complete the following steps:

   1. Add an entry to `data_sources` similar to the other listed entries. For example:

      ```yaml
      -  # Documentation from https://gitlab.com/<repo>
        type: filesystem
        items_root: /<slug>/
        content_dir: ../<product_name>/<doc_dir>
        layouts_dir: null
        encoding: utf-8
        identifier_type: full
      ```

      Where:

      - `items_root`: The subdirectory where the docs will be hosted. This will end up being `https://docs.gitlab.com/<slug>`.
      - `content_dir`: The relative path where the docs reside. This normally points to the repository you cloned in the first step.

   1. Add the product's details under the `products` key:

      ```yaml
      <product_name>:
        slug: '<product_name_slug>'
        repo: 'https://gitlab.com/<repo>.git'
        project_dir: '../product_name'
        content_dir: '../product_name/<doc_dir>'
      ```

      Where:

      - `<product_name>`: Used by other parts of code (for example `lib/task_helpers.rb`).
      - `slug`: Used in the Rakefile. Usually the same as the product name.
      - `project_dir`: The repository of the product, relative to the `gitlab-docs` repository.
      - `content_dir`: The product's documentation directory. This is the same as the `content_dir` defined in `data_sources`.

1. Edit [`lib/task_helpers.rb`](../lib/tasks/task_helpers.rb) and add the `<product_name>` to the `PRODUCTS` variable. For example:

   ```ruby
   PRODUCTS = %w[ee omnibus runner charts <product_name>].freeze
   ```

   If the product has a different stable branch naming scheme than what is
   already in this file, you need to add another
   [when statement](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/68814c875e322b1871d6368135af49794041ddd1/lib/task_helpers.rb#L20-44)
   that takes care of that. Otherwise, if the product doesn't have a stable
   branch at all, you can omit this and the default branch will be always pulled.

1. Edit ['lib/edit_on_gitlab.rb'](../lib/helpers/edit_on_gitlab.rb) and add the product and its attributes to the `PRODUCT_REPOS` object, then add 1-2 test cases in [`spec/lib/helpers/edit_on_gitlab_spec.rb`](../spec/lib/helpers/edit_on_gitlab_spec.rb).
1. Edit [`.gitlab-ci.yml`](../.gitlab-ci.yml) and add the new `BRANCH_<slug>` variable under `variables`. For example, if the slug is named `foo`, the variable should be named `BRANCH_FOO`.
1. Edit [`.test.gitlab-ci.yml`](../.gitlab/ci/test.gitlab-ci.yml) and add the new product to the following tests, following the same pattern as existing products:

   - `test_global_nav_links`
   - `test_EOL_whitespace`
   - `test_unlinked_images`

1. Edit [`scripts/normalize-links.sh`](../scripts/normalize-links.sh)
   and add the new product to the `Relative URLs` and `Full URLs` sections.
1. Edit the ['Makefile'](../Makefile):

   - Add a command to clone the repository, and add it to `clone-all-docs-projects`. See `../gitlab-operator/.git` as an example.
   - Add a command to update the repository, and add it to `update-all-docs-projects`. See `update-gitlab-operator` as an example.
   - Add a command to check for the existence of content, and add it to `check-for-all-content`. See `check-for-charts-gitlab-content` as an example.

1. Update `gitlab-docs` documentation:

   - Add the new product to the list in [`doc/index.md`](../doc/index.md).
   - Add the new product to the diagram in [`doc/architecture.md`](../doc/architecture.md).
   - Add the new product environment variable (`BRANCH_<slug>`) in [`doc/raketasks.md`](../doc/raketasks.md#clone-an-upstream-branch-other-than-the-default).

1. Add new whitespace test target to `markdownlint-whitespace-tests-gitlab` in `Makefile`.

## Exclude a directory

To exclude a directory so the contents aren't published to the docs site:

1. Edit [this `Rules` file](../Rules).
1. Add an `ignore` line, like: `ignore '/ee/drawers/*.md'`.

# GitLab docs site development

## Linking to source files

A helper called [`edit_on_gitlab`](/lib/helpers/edit_on_gitlab.rb) can be used
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

## Modern JavaScript

A lot of the JavaScript can be found in [`content/assets/javascripts/`](https://gitlab.com/gitlab-org/gitlab-docs/-/tree/main/content/assets/javascripts/content/assets/javascripts).
The files in this directory are handcrafted `ES5` JavaScript files.

We've [recently introduced](https://gitlab.com/gitlab-org/gitlab-docs/merge_requests/577)
the ability to write modern JavaScript. All modern JavaScript should be added to
the [content/frontend/](https://gitlab.com/gitlab-org/gitlab-docs/-/tree/main/content/frontend) directory.

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

### Add a global library

Libraries that are not specific to individual components (e.g, jQuery) are bundled via `global_imports.js`. The resulting build is included on all pages.

This is a pattern to avoid going forward -- ideally third-party libraries are only loaded from components that require them -- but this allows us to utilize yarn for package management and avoid external CDNs while the site is still only partially component-driven.

## Bump versions of JavaScript

Whenever the JavaScript files under `content/assets/` change,
make sure to bump their version in the front matter. This method guarantees that
your changes take effect by clearing the cache of previous files.

Always use Nanoc's way of including those files, do not hardcode them in the
layouts. For example use:

```js
<script async type="application/javascript" src="<%= @items['/assets/javascripts/badges.*'].path %>"></script>
```

The links pointing to the files should be similar to:

```js
<%= @items['/path/to/assets/file.*'].path %>
```

Nanoc then builds and renders those links correctly according with what's
defined in [`Rules`](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/Rules).

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

- Due to licensing restrictions, consider an alternative to Docker Desktop. There are several suggestions in [the handbook](https://about.gitlab.com/handbook/tools-and-tips/mac/#docker-desktop). Colima works well with the above script.
- M1 Macs require an environment variable in order to run these images:

  ```shell
  export DOCKER_DEFAULT_PLATFORM=linux/amd64
  ```

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

1. Edit [`lib/task_helpers.rb`](../lib/task_helpers.rb) and add the `<product_name>` to the `PRODUCTS` variable. For example:

   ```ruby
   PRODUCTS = %w[ee omnibus runner charts <product_name>].freeze
   ```

   If the product has a different stable branch naming scheme than what is
   already in this file, you need to add another
   [when statement](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/68814c875e322b1871d6368135af49794041ddd1/lib/task_helpers.rb#L20-44)
   that takes care of that. Otherwise, if the product doesn't have a stable
   branch at all, you can omit this and the default branch will be always pulled.

1. Edit ['lib/edit_on_gitlab.rb'](../lib/edit_on_gitlab.rb) and add the product and its attributes to the `PRODUCT_REPOS` object, then add 1-2 test cases in [`spec/lib/helpers/edit_on_gitlab_spec.rb`](../spec/lib/helpers/edit_on_gitlab_spec.rb).

1. Edit [`.test.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/.gitlab/ci/test.gitlab-ci.yml) and add the new product to the following tests, following the same pattern as existing products:

- `test_global_nav_links`
- `test_EOL_whitespace`
- `test_unlinked_images`

1. Edit [`scripts/normalize-links.sh`](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/scripts/normalize-links.sh)
   and add the new product to the `Relative URLs` and `Full URLs` sections.

1. Edit the ['Makefile'](../Makefile):

   - Add a command to clone the repository, and add it to `clone-all-docs-projects` (see `../gitlab-operator/.git` as an example).
   - Add a command to update the repository, and add it to `update-all-docs-projects` (see `update-gitlab-operator`) as an example).

1. Update `gitlab-docs` documentation:

   - Add the new product to the list in [`doc/index.md`](../doc/index.md).
   - Add the new product to the diagram in [`doc/architecture.md`](../doc/architecture.md).

## Exclude a directory

To exclude a directory so the contents aren't published to the docs site:

1. Edit [this `Rules` file](https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/Rules).
1. Add an `ignore` line, like: `ignore '/ee/drawers/*.md'`.

# Set up, preview, and update GitLab Docs site

You can set up, compile, update, and preview the GitLab Docs site locally.

Alternatively, you can use either:

- [GitPod](#using-gitpod).
- A [Workspace](#using-a-workspace).
- [GDK](https://gitlab.com/gitlab-org/gitlab-development-kit/-/blob/main/doc/howto/gitlab_docs.md), if you already
  have GDK configured.

## Set up GitLab Docs locally

GitLab Docs requires [Git](https://git-scm.com) and Make (for example, [GNU Make](https://www.gnu.org/software/make/)).
To check they are installed, run:

```shell
which git && which make
```

If they aren't installed, use Homebrew or your Linux distribution's package manager to install them.

Homebrew is also useful for installing other packages you might be missing. To install Homebrew, follow the guide at <https://brew.sh>.

To set up GitLab Docs:

1. [Install `asdf`](https://asdf-vm.com/guide/getting-started.html) and its dependencies. To complete the `asdf` installation, close the
   terminal you used to install `asdf` and open a new terminal. That enables `asdf` for later steps.
1. Clone the `gitlab-docs` project.
1. In the checkout of `gitlab-docs`, run:

   ```shell
   make setup
   ```

If you have trouble installing Ruby on Linux using `make setup`, you might be missing a
[compatible version of OpenSSL](https://bugs.ruby-lang.org/issues/18658). The solution can vary between different
distributions and versions. For some additional information, see
[Ruby troubleshooting information](https://gitlab.com/gitlab-org/gitlab-development-kit/-/blob/main/doc/troubleshooting/ruby.md#openssl-3-breaks-ruby-builds)
for GDK.

An alternative to `make setup` is to follow [Advanced setup for GitLab Docs](advanced_setup.md).

### Clone all documentation repositories

To build the full GitLab documentation website locally, you must clone all the documentation projects that provide the
Nanoc [data sources](../nanoc.yaml). To clone all documentation
projects, run the following in the checkout of `gitlab-docs`:

```shell
make clone-all-docs-projects
```

The documentation projects are cloned into the parent directory. If you make documentation changes in these projects, they can be previewed.

### Preview GitLab Docs

1. In the checkout of `gitlab-docs`, run the following command:

   ```shell
   make view
   ```

   When the preview preparation process finishes, you should see
   the following output in the terminal:

   ```shell
   INFO: Starting GitLab documentation site...
   View the site at http://127.0.0.1:3000/
   ```

1. To open the preview, in your browser, go to the URL in the terminal output.
   For this example, go to <http://127.0.0.1:3000/>.

1. From your preview homepage, use the docs site navigation to go to the page you want to preview.

   Do not use the search box, as search results take you to the live docs site.

1. If you make changes to any of the documentation in any of the documentation projects, rerun `make view` to see an
updated preview.

### Preview on mobile

If you want to check how your changes look on mobile devices, you can use:

- [Responsive Design Mode](https://support.apple.com/en-au/guide/safari-developer/dev84bd42758/mac)
  on Safari.
- [Responsive Design Mode](https://developer.mozilla.org/en-US/docs/Tools/Responsive_Design_Mode)
  on Firefox.
- [Device Mode](https://developers.google.com/web/tools/chrome-devtools/device-mode)
  on Chrome.

An alternative is to preview the documentation site with your own devices, as long as they are connected to the same
network as your computer:

1. Find your computer's [private IPv4 address](https://www.howtogeek.com/236838/how-to-find-any-devices-ip-address-mac-address-and-other-network-connection-details/).
1. Pass the private IPv4 address to Nanoc using the `-o` flag. For example, if your current IPv4 address is `192.168.0.105`:

   ```shell
   bundle exec nanoc live -o 192.168.0.105
   ```

1. Open your mobile device's browser and type `http://192.168.0.105:3000` (if your current IPv4 address is `192.168.0.105`).
   You should be able to navigate through the GitLab Docs site. This process applies to previewing the GitLab Docs site
   on every device connected to your network.

### Update GitLab Docs

To update GitLab Docs itself, run:

```shell
make update
```

To update GitLab Docs and all documentation projects, run:

```shell
make update-all-projects
```

## Using Gitpod

[Gitpod](https://www.gitpod.io) is a online environment with pre-configured GitLab Docs site ready for development. You can use Gitpod as
an alternative to building and maintaining a local environment for running the GitLab Docs site.

For more information, see the [GDK Gitpod docs](https://gitlab.com/gitlab-org/gitlab-development-kit/-/blob/main/doc/howto/gitpod.md).

### Set up Gitpod

To set up Gitpod:

1. Create a [Gitpod](https://www.gitpod.io) account and connect it to your GitLab account.
1. Enable the integration in your GitLab [profile preferences](https://gitlab.com/-/profile/preferences).
1. Open the GitLab documentation site in Gitpod:

   - If you're a GitLab team member, open the
     [GitLab documentation site environment](https://gitpod.io/#https://gitlab.com/gitlab-org/gitlab-docs/).

   - If you're a community contributor:

     1. Fork the [GitLab Docs repository](https://gitlab.com/gitlab-org/gitlab-docs/-/forks/new).
     1. Select **Gitpod** in the repository view of your fork. If you don't see
        **Gitpod**, open the **Web IDE** dropdown.

### Check out branches in Gitpod

To switch to another branch:

1. In the bottom blue bar, select the current branch name. GitLab displays a
   context menu with a list of branches.
1. Enter the name of the branch you want to switch to, and then select it from
   the list.
1. To create a new branch, select **Create new branch**, provide a name for the
   branch, and then press <kbd>Enter</kbd>.

### Commit and push changes in Gitpod

To commit and push changes:

1. In the left sidebar, select the **Source Control: Git** tab.
1. Review the displayed changes you want to add to the commit. To add all files,
   select the **Plus** icon next to the **Changes** section.
1. Enter a commit message in the text area.
1. Select the checkmark icon at the top of the **Source Control** section to
   commit your changes.
1. Push your changes by selecting the **Synchronize changes** action in the bottom blue toolbar. If Gitpod asks you how you want to
   synchronize your changes, select **Push and pull**.

## Using a workspace

[Workspaces](https://docs.gitlab.com/ee/user/workspace/index.html) provide an environment for opening the `gitlab-docs`
project in a running Docker container where you can preview GitLab documentation.

To open GitLab Docs in a workspace

1. Go to the `gitlab-docs` project page: <https://gitlab.com/gitlab-org/gitlab-docs>.
1. Next to the **Find file** button, select **Edit**.
1. Select **New workspace**.
1. In the **Select cluster agent** dropdown, select the only option available.
1. Select **Create workspace**.
1. In the **Preview** column, wait for a link to appear and then select the link.

The workspace opens with a view of the the `gitlab-docs` source code.

To preview documentation:

1. From the hamburger menu, select **Terminal** > **New Terminal**.
1. In the terminal window, run `make setup`.
1. (Optional) To make all the GitLab documentation content available, run `bundle exec rake clone_repositories`.
1. Run `make compile`.
1. To load the documentation preview, run `bundle exec nanoc view --host 0.0.0.0`.

The preview is available at a URL with the following pattern: `https://3000-workspace-<...>.workspaces.gitlab.dev`,
which is based on the URL of the workspace.

## Troubleshooting

### Dependency errors when running `make view`

When running `make view`, you might get an error about a missing tool or dependency.
For example, you might need a new version of Ruby.

To install and update the dependencies needed to preview docs locally, run:

```shell
make setup
```

### Error: `WARNING: <documentation project> documentation is missing`

When building documentation, you might receive one of the following errors in the terminal:

- `WARNING: GitLab documentation is missing.`
- `WARNING: GitLab Runner documentation is missing.`
- `WARNING: Omnibus GitLab documentation is missing.`
- `WARNING: GitLab Charts documentation is missing.`
- `WARNING: GitLab Operator documentation is missing.`

In many cases, this warning is expected because you're only building some of the documentation suite. If you expect all
of the documentation to be available to build, and some or all of it is missing, you might need to clone or update more
projects.

To make sure all documentation projects are in place, run `make` with the required target. For example:

- To make sure GitLab Charts documentation is in place and up to date, run `make update-charts-gitlab`.
- To make sure all project documentation is in place and up to date, run `make update-all-docs-projects`.

You can clone all repositories:

- Using SSH by running `make clone-all-docs-projects`.
- Using HTTPS by running `bundle exec rake clone_repositories`.

For more:

- `make` targets, see: [`Makefile`](../Makefile).
- Rake tasks, see: [`Rakefile`](../Rakefile).

### `realpath: No such file or directory @ rb_check_realpath_internal`

If you run into this error, it means you're missing one of the projects `gitlab-docs` relies on to build the content of the GitLab Docs site.
To resolve this error, run:

```shell
make clone-all-docs-projects
```

### `requires ruby version >= 2.7.0, which is incompatible with the current version, ruby 2.6.8p205`

You can encounter this error when running `make setup`, even though you installed the required Ruby version with `asdf`. It usually
means that your shell is pointing to the wrong Ruby installation. macOS comes with versions of Ruby that are too old for `gitlab-docs`.

```shell
# check system Ruby version
/usr/bin/ruby --version

# check asdf Ruby version
/Users/<username>/.asdf/shims/ruby --version
```

The system and asdf versions of Ruby are likely to match the versions in the error. To solve this error, you must configure your shell to
point to the `asdf` version instead of the system version.

1. Check the [install `asdf`](https://asdf-vm.com/guide/getting-started.html#_3-install-asdf) instructions, and make sure you used the method
   that matches the way you [downloaded `asdf`](https://asdf-vm.com/guide/getting-started.html#_2-download-asdf) and the shell you use. If
   you didn't use the matching instructions, perform the required steps.
1. Check that `asdf` is configured in your shell's configuration as specified in the asdf instructions. For example, if you use ZSH:

   ```shell
   cat .zshrc
   ```

1. Open a new terminal window and check that the shell points to the required Ruby version:

   ```shell
   which ruby
   ruby --version
   ```

### `An error occurred while installing eventmachine (1.2.7), and Bundler cannot continue`

You can encounter this error if you run `make view` and don't have OpenSSL installed on your machine. To resolve this
error for macOS:

1. Optional. Install [Brew](https://brew.sh/) if required.
1. Run `make brew-bundle`.
1. Install EventMachine:

   ```plaintext
   gem install eventmachine -- --with-openssl-dir=$(brew --prefix)/opt/openssl@1.1
   ```

### `Address already in use - bind(2) for 127.0.0.1:3000`

You can encounter this error if you run `make view` whilst running the [GitLab Development Kit (GDK)](https://gitlab.com/gitlab-org/gitlab-development-kit/-/blob/main/doc/index.md) server on the same port, which is `3000` in this example.

To resolve this error, specify a custom port with:

```shell
make view PORT=4000
```

Alternatively, you can
[configure GDK](https://gitlab.com/gitlab-org/gitlab-development-kit/-/blob/main/doc/configuration.md#notable-settings)
to use another port, for example, `3001`:

1. In your local `gitlab-development-kit` repository, add the following line to `gdk.yml`:

   ```yaml
   port: 3001
   ```

1. Reconfigure GDK by running:

   ```plaintext
   gdk reconfigure
   ```

1. In your local `gitlab-docs` repository, run:

   ```plaintext
   make view
   ```

For a temporary solution, stop the GDK server before running `make view`.

1. In your local `gitlab-development-kit` repository:
   1. Run `gdk stop` to stop the GDK services.
   1. Run `gdk status` to check if the GDK services are now down. If this is the case, the output is similar to:

   ```shell
   down: /Users/<username>/Documents/gitlab-development-kit/services/gitlab-docs: 44s; run: log: (pid 15870) 44s
   down: /Users/<username>/Documents/gitlab-development-kit/services/gitlab-workhorse: 44s; run: log: (pid 15864) 44s
   down: /Users/<username>/Documents/gitlab-development-kit/services/postgresql: 44s; run: log: (pid 15862) 44s
   down: /Users/<username>/Documents/gitlab-development-kit/services/praefect: 44s; run: log: (pid 15863) 44s
   down: /Users/<username>/Documents/gitlab-development-kit/services/praefect-gitaly-0: 44s; run: log: (pid 15861) 44s
   down: /Users/<username>/Documents/gitlab-development-kit/services/rails-background-jobs: 44s; run: log: (pid 15869) 44s
   down: /Users/<username>/Documents/gitlab-development-kit/services/rails-web: 44s; run: log: (pid 15865) 44s
   down: /Users/<username>/Documents/gitlab-development-kit/services/redis: 44s; run: log: (pid 15868) 44s
   down: /Users/<username>/Documents/gitlab-development-kit/services/sshd: 44s; run: log: (pid 15867) 44s
   down: /Users/<username>/Documents/gitlab-development-kit/services/webpack: 44s; run: log: (pid 15866) 44s
   ```

1. In your local `gitlab-docs` repository, run:

   ```plaintext
   make view
   ```

### Missing gems when updating Ruby

When a new Ruby version is added in `.tool-versions`, you can install it with:

```shell
make install-asdf-dependencies
```

After the installation completes, you must re-install the Gems. Run the
following command in all repositories that need Ruby (for example, `gitlab`,
`gitlab-docs`):

```shell
bundle install
```

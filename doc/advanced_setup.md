# Advanced setup for GitLab Docs

Instead of relying on `make setup` in the [basic setup instructions](setup.md), you can install GitLab Docs
dependencies yourself. The dependencies are:

- System dependencies. The list of required software is in [Brewfile](/Brewfile). On Linux, install these packages manually.
- Ruby.
- Node.js and Yarn.

## Install Ruby

To install Ruby using [`rbenv`](https://github.com/rbenv/rbenv):

1. [Install `rbenv`](https://github.com/rbenv/rbenv#installation).
1. Install the [supported version of Ruby](../.ruby-version):

   ```shell
   rbenv install <supported-version>
   ```

1. Use the newly-installed Ruby:

   ```shell
   rbenv global <supported-version>
   ```

Check your:

- Ruby version with `ruby --version`.
- Bundler version with `bundle --version`.

## Install Node.js

To install Node.js using [`nvm`](https://github.com/nvm-sh/nvm):

1. [Install `nvm`](https://github.com/nvm-sh/nvm#installation-and-update).
1. Install the [supported version of Node.js](../.nvmrc):

   ```shell
   nvm install <supported-version>
   ```

1. Use the newly-installed Node.js:

   ```shell
   nvm use <supported-version> --default
   ```

Check your Node.js version with `node -v`.

### Install Yarn

Install [Yarn](https://yarnpkg.com), a package manager for the Node.js ecosystem.

#### Upgrade Yarn

If you have Yarn 1.x installed globally, you must enable [Corepack](https://github.com/nodejs/corepack?tab=readme-ov-file#-corepack) to upgrade to Yarn 4.x in this project.

```shell
corepack enable
```

Corepack sets the version of Yarn specified in this project's [`package.json`](../package.json) file. You can verify the version you're using by running:

```shell
yarn --version
```

Corepack does not install globally, so this should not impact other projects where you may have different versions of Yarn.

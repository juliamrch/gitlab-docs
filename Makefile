.PHONY: all clean setup test up

INFO = \033[32m
ERROR = \033[31m
END = \033[0m

../gitlab/.git:
	@echo "\n$(INFO)INFO: Cloning GitLab project into parent directory...$(END)\n"
	@git clone git@gitlab.com:gitlab-org/gitlab.git ../gitlab

../gitlab-runner/.git:
	@printf "\n$(INFO)INFO: Cloning GitLab Runner project into parent directory...$(END)\n"
	@git clone git@gitlab.com:gitlab-org/gitlab-runner.git ../gitlab-runner

../omnibus-gitlab/.git:
	@printf "\n$(INFO)INFO: Cloning Omnibus GitLab project into parent directory...$(END)\n"
	@git clone git@gitlab.com:gitlab-org/omnibus-gitlab.git ../omnibus-gitlab

../charts-gitlab/.git:
	@printf "\n$(INFO)INFO: Cloning GitLab Chart project into parent directory...$(END)\n"
	@git clone git@gitlab.com:gitlab-org/charts/gitlab.git ../charts-gitlab

../gitlab-operator/.git:
	@printf "\n$(INFO)INFO: Cloning GitLab Operator project into parent directory...$(END)\n"
	@git clone git@gitlab.com:gitlab-org/cloud-native/gitlab-operator.git ../gitlab-operator

clone-all-docs-projects: ../gitlab/.git ../gitlab-runner/.git ../omnibus-gitlab/.git ../charts-gitlab/.git ../gitlab-operator/.git

update-gitlab: ../gitlab/.git
	@printf "\n$(INFO)INFO: Stashing any changes, switching to master branch, and pulling updates to GitLab project...$(END)\n"
	@cd ../gitlab && git stash && git checkout master && git pull --ff-only

update-gitlab-runner: ../gitlab-runner/.git
	@printf "\n$(INFO)INFO: Stashing any changes, switching to main branch, and pulling updates to GitLab Runner project...$(END)\n"
	@cd ../gitlab-runner && git stash && git checkout main && git pull --ff-only

update-omnibus-gitlab: ../omnibus-gitlab/.git
	@printf "\n$(INFO)INFO: Stashing any changes, switching to master branch, and pulling updates to Omnibus GitLab project...$(END)\n"
	@cd ../omnibus-gitlab && git stash && git checkout master && git pull --ff-only

update-charts-gitlab: ../charts-gitlab/.git
	@printf "\n$(INFO)INFO: Stashing any changes, switching to master branch, and pulling updates to GitLab Chart project...$(END)\n"
	@cd ../charts-gitlab && git stash && git checkout master && git pull --ff-only

update-gitlab-operator: ../gitlab-operator/.git
	@printf "\n$(INFO)INFO: Stashing any changes, switching to master branch, and pulling updates to GitLab Operator project...$(END)\n"
	@cd ../gitlab-operator && git stash && git checkout master && git pull --ff-only

update-all-docs-projects: update-gitlab update-gitlab-runner update-omnibus-gitlab update-charts-gitlab update-gitlab-operator

up: setup view

compile: setup
	@printf "\n$(INFO)INFO: Compiling GitLab documentation site...$(END)\n"
	@bundle exec nanoc compile

view: compile
	@printf "\n$(INFO)INFO: Starting GitLab documentation site...$(END)\n"
	@bundle exec nanoc view

live: compile
	@printf "\n$(INFO)INFO: Starting GitLab documentation site with live reload...$(END)\n"
	@bundle exec nanoc live

check-asdf:
	@printf "\n$(INFO)INFO: Checking asdf is available...$(END)\n"
ifeq ($(shell command -v asdf 2> /dev/null),)
	@printf "$(ERROR)ERROR: asdf not found!$(END)\nFor more information, see: https://asdf-vm.com/guide/getting-started.html.$(END)\n"
	@exit 1
else
	@printf "$(INFO)INFO: asdf found!$(END)\n"
endif

setup-asdf: check-asdf
	@printf "\n$(INFO)INFO: Installing asdf plugins...$(END)\n"
	@asdf plugin add ruby || true
	@asdf plugin add nodejs || true
	@asdf plugin add yarn || true
	@printf "\n$(INFO)INFO: Updating asdf plugins...$(END)\n"
	@asdf plugin update ruby
	@asdf plugin update nodejs
	@asdf plugin update yarn

install-asdf-dependencies:
	@printf "\n$(INFO)INFO: Installing asdf dependencies...$(END)\n"
	@asdf install

install-ruby-dependencies:
	@printf "\n$(INFO)INFO: Installing Ruby dependencies...$(END)\n"
	@bundle install

install-nodejs-dependencies:
	@yarn install --frozen-lockfile --silent

setup: brew-bundle setup-asdf install-asdf-dependencies install-ruby-dependencies install-nodejs-dependencies

update:
	@printf "\n$(INFO)INFO: Stashing any changes, switching to main branch, and pulling updates to GitLab Docs project...$(END)\n"
	@git stash && git checkout main && git pull --ff-only

update-all-projects: update update-all-docs-projects

clean:
	@printf "\n$(INFO)INFO: Removing tmp and public directories...$(END)\n"
	@rm -rf tmp public

build-lunr-index:
	@printf "\n$(INFO)INFO: Building offline search index..$(END)\n"
	node scripts/lunr/preindex.js

check-lunr-index:
	@printf "\n$(INFO)INFO: Checking if lunr.js is enabled...$(END)\n"
	@scripts/check-lunr-index.sh

internal-links-check: clone-all-docs-projects compile
	@printf "\n$(INFO)INFO: Checking all internal links...$(END)\n"
	@bundle exec nanoc check internal_links

internal-anchors-check: clone-all-docs-projects compile
	@printf "\n$(INFO)INFO: Checking all internal anchors...$(END)\n"
	@bundle exec nanoc check internal_anchors

internal-links-and-anchors-check: clone-all-docs-projects compile
	@printf "\n$(INFO)INFO: Checking all internal links and anchors...$(END)\n"
	@parallel time bundle exec nanoc check ::: internal_links internal_anchors

external-links-check: compile
	@printf "\n$(INFO)INFO: Checking all external links...$(END)\n"
	@bundle exec nanoc check external_links

brew-bundle:
	@printf "\n$(INFO)INFO: Checking Brew dependencies, if Brew is available...$(END)\n"
	@(command -v brew > /dev/null 2>&1) && brew bundle --no-lock || true

rspec-tests:
	@printf "\n$(INFO)INFO: Running RSpec tests...$(END)\n"
	@bundle exec rspec

jest-tests:
	@printf "\n$(INFO)INFO: Running Jest tests...$(END)\n"
	@yarn test

eslint-tests:
	@printf "\n$(INFO)INFO: Running ESLint tests...$(END)\n"
	@yarn eslint

prettier-tests:
	@printf "\n$(INFO)INFO: Running Prettier tests...$(END)\n"
	@yarn prettier

stylelint-tests:
	@printf "\n$(INFO)INFO: Running Stylelint tests...$(END)\n"
	@yarn stylelint content/assets/stylesheets

hadolint-tests:
	@printf "\n$(INFO)INFO: Running hadolint tests...$(END)\n"
	@hadolint latest.Dockerfile .gitpod.Dockerfile **/*.Dockerfile

yamllint-tests:
	@printf "\n$(INFO)INFO: Running yamllint tests...$(END)\n"
	@yamllint .gitlab-ci.yml content/_data

markdownlint-tests:
	@printf "\n$(INFO)INFO: Running markdownlint tests...$(END)\n"
	@yarn markdownlint doc/**/*.md

shellcheck-tests:
	@printf "\n$(INFO)INFO: Running shellcheck tests...$(END)\n"
	@shellcheck scripts/*.sh tasks/*.sh

check-global-navigation:
	@printf "\n$(INFO)INFO: Checking global navigation...$(END)\n"
	@scripts/check-navigation.sh

check-pages-not-in-nav: install-nodejs-dependencies
	@scripts/pages_not_in_nav.js | jq

test: setup rspec-tests jest-tests eslint-tests prettier-tests stylelint-tests hadolint-tests yamllint-tests markdownlint-tests check-global-navigation

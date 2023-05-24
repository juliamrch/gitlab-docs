.PHONY: all clean setup test up

INFO = \033[32m
ERROR = \033[31m
END = \033[0m

PORT := 3000

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

check-google-search-key:
ifeq ($(GOOGLE_SEARCH_KEY),)
	@printf "\n$(INFO)INFO: GOOGLE_SEARCH_KEY environment variable not detected! For more information, see https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/search.md.$(END)\n"
else
	@printf "\n$(INFO)INFO: GOOGLE_SEARCH_KEY environment variable detected!$(END)\n"
endif

.PHONY: compile
compile:
ifeq ($(SEARCH_BACKEND),lunr)
	@printf "\n$(INFO)INFO: Compiling GitLab documentation site with Lunr.js search...$(END)\n"
	@bundle exec nanoc compile || (printf "$(ERROR)ERROR: Compilation failed! Try running 'make setup'.$(END)\n" && exit 1)
	$(MAKE) build-lunr-index
else ifeq ($(SEARCH_BACKEND),google)
	@printf "\n$(INFO)INFO: Compiling GitLab documentation site with Google Programmable Search...$(END)\n"
	$(MAKE) check-google-search-key
	@bundle exec nanoc compile || (printf "$(ERROR)ERROR: Compilation failed! Try running 'make setup'.$(END)\n" && exit 1)
else ifeq ($(SEARCH_BACKEND),)
	@printf "\n$(INFO)INFO: No search backend specified. Compiling GitLab documentation site with Google Programmable Search...$(END)\n"
	$(MAKE) check-google-search-key
	@bundle exec nanoc compile || (printf "$(ERROR)ERROR: Compilation failed! Try running 'make setup'.$(END)\n" && exit 1)
else
	@printf "\n$(ERROR)ERROR: Invalid search backend specified!$(END)\n" && exit 1
endif

view: compile
	@printf "\n$(INFO)INFO: Starting GitLab documentation site...$(END)\n"
	@bundle exec nanoc view -p $(PORT)

live: compile
	@printf "\n$(INFO)INFO: Starting GitLab documentation site with live reload...$(END)\n"
	@bundle exec nanoc live -p $(PORT)

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
	@asdf plugin add shellcheck || true
	@printf "\n$(INFO)INFO: Updating asdf plugins...$(END)\n"
	@asdf plugin update ruby
	@asdf plugin update nodejs
	@asdf plugin update yarn
	@asdf plugin update shellcheck

install-asdf-dependencies:
	@printf "\n$(INFO)INFO: Installing asdf dependencies...$(END)\n"
	@asdf install

install-ruby-dependencies:
	@printf "\n$(INFO)INFO: Installing Ruby dependencies...$(END)\n"
	@gem update --system --no-document
	@bundle install

install-nodejs-dependencies:
	@yarn install --frozen-lockfile --silent

setup: clean brew-bundle setup-asdf install-asdf-dependencies install-ruby-dependencies install-nodejs-dependencies

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
	@yarn test:vue3

eslint-tests:
	@printf "\n$(INFO)INFO: Running ESLint tests...$(END)\n"
	@yarn eslint

prettier-tests:
	@printf "\n$(INFO)INFO: Running Prettier tests...$(END)\n"
	@yarn prettier

rubocop-tests:
	@printf "\n$(INFO)INFO: Running RuboCop tests...$(END)\n"
	@bundle exec rubocop

stylelint-tests:
	@printf "\n$(INFO)INFO: Running Stylelint tests...$(END)\n"
	@yarn stylelint content/assets/stylesheets

hadolint-tests:
	@printf "\n$(INFO)INFO: Running hadolint tests...$(END)\n"
	@hadolint latest.Dockerfile .gitpod.Dockerfile **/*.Dockerfile

yamllint-tests:
	@printf "\n$(INFO)INFO: Running yamllint tests...$(END)\n"
	@yamllint .gitlab-ci.yml .gitpod.yml content/_data

markdownlint-tests:
	@printf "\n$(INFO)INFO: Running markdownlint tests...$(END)\n"
	@yarn markdownlint-cli2 doc/**/*.md

markdownlint-whitespace-tests-gitlab:
	@printf "\n$(INFO)INFO: Running markdownlint whitespace tests on GitLab project...$(END)\n"
	@cd ../gitlab/doc && markdownlint-cli2-config "../../gitlab-docs/tasks/.markdownlint.yml" "**/*.md"

markdownlint-whitespace-tests-gitlab-runner:
	@printf "\n$(INFO)INFO: Running markdownlint whitespace tests on GitLab Runner project...$(END)\n"
	@cd ../gitlab-runner/docs && markdownlint-cli2-config "../../gitlab-docs/tasks/.markdownlint.yml" "**/*.md"

markdownlint-whitespace-tests-omnibus-gitlab:
	@printf "\n$(INFO)INFO: Running markdownlint whitespace tests on Omnibus GitLab project...$(END)\n"
	@cd ../omnibus-gitlab/doc && markdownlint-cli2-config "../../gitlab-docs/tasks/.markdownlint.yml" "**/*.md"

markdownlint-whitespace-tests-charts-gitlab:
	@printf "\n$(INFO)INFO: Running markdownlint whitespace tests on GitLab Chart project...$(END)\n"
	@cd ../charts-gitlab/doc && markdownlint-cli2-config "../../gitlab-docs/tasks/.markdownlint.yml" "**/*.md"

markdownlint-whitespace-tests-gitlab-operator:
	@printf "\n$(INFO)INFO: Running markdownlint whitespace tests on GitLab Operator project...$(END)\n"
	@cd ../gitlab-operator/doc && markdownlint-cli2-config "../../gitlab-docs/tasks/.markdownlint.yml" "**/*.md"

markdownlint-whitespace-tests: install-nodejs-dependencies
	@$(MAKE) markdownlint-whitespace-tests-gitlab || true
	@$(MAKE) markdownlint-whitespace-tests-gitlab-runner || true
	@$(MAKE) markdownlint-whitespace-tests-omnibus-gitlab || true
	@$(MAKE) markdownlint-whitespace-tests-charts-gitlab || true
	@$(MAKE) markdownlint-whitespace-tests-gitlab-operator || true

shellcheck-tests:
	@printf "\n$(INFO)INFO: Running shellcheck tests...$(END)\n"
	@shellcheck scripts/*.sh tasks/*.sh

check-global-navigation:
	@printf "\n$(INFO)INFO: Checking global navigation...$(END)\n"
	@scripts/check-navigation.sh

check-pages-not-in-nav: install-nodejs-dependencies
	@scripts/pages_not_in_nav.js | jq

check-danger:
	@printf "\n$(INFO)INFO: Checking for Danger errors and warnings...$(END)\n"
	@scripts/check-danger.sh ; exit $$?

add-gitlab-fonts:
	@printf "\n$(INFO)INFO: Copying GitLab fonts...$(END)\n"
	cp -v node_modules/@gitlab/fonts/gitlab-sans/GitLabSans.woff2 public/assets/fonts
	cp -v node_modules/@gitlab/fonts/jetbrains-mono/JetBrainsMono* public/assets/fonts

create-stable-branch:
	@printf "\n$(INFO)INFO: Creating stable branch...$(END)\n"
	@bundle exec rake release:single

test: setup rspec-tests jest-tests eslint-tests prettier-tests stylelint-tests hadolint-tests yamllint-tests markdownlint-tests check-global-navigation

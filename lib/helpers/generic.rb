# frozen_string_literal: true

module Nanoc::Helpers
  module Generic
    #
    # Check if NANOC_ENV is set to production
    #
    def production?
      ENV['NANOC_ENV'] == 'production'
    end

    #
    # Check if NANOC_ENV is set to production and the branch is the default one.
    # For things that should only be built in production of the default branch.
    # Sometimes we don't want things to be deployed into the stable branches,
    # which they are considered production.
    #
    def production_and_default_branch?
      ENV['NANOC_ENV'] == 'production' && ENV['CI_DEFAULT_BRANCH'] == ENV['CI_COMMIT_REF_NAME']
    end

    #
    # Used when bundling gitlab-docs with Omnibus
    #
    def omnibus?
      ENV['NANOC_ENV'] == 'omnibus'
    end

    #
    # Find the current branch. If CI_COMMIT_BRANCH is not defined, that means
    # we're working locally, and Git is used to find the branch.
    #
    def current_branch
      if ENV['CI_COMMIT_REF_NAME'].nil?
        `git branch --show-current`.tr("\n", '')
      else
        ENV['CI_COMMIT_REF_NAME']
      end
    end

    #
    # Check if CI_PROJECT_NAME is 'gitlab-docs', or nil which implies
    # local development. This can be used to skip portions that we
    # don't want to render in one of the upstream products.
    #
    def gitlab_docs_or_local?
      ENV['CI_PROJECT_NAME'] == 'gitlab-docs' or ENV['CI_PROJECT_NAME'].nil?
    end

    #
    # Control display of survey banner. See README.md#survey-banner
    #
    def show_banner?
      @items['/_data/banner.yaml'][:show_banner]
    end
  end
end

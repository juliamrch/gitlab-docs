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
      ENV['CI_PROJECT_NAME'] == 'gitlab-docs' || ENV['CI_PROJECT_NAME'].nil?
    end

    #
    # Control display of survey banner. See README.md#survey-banner
    #
    def show_banner?
      @items['/_data/banner.yaml'][:show_banner]
    end

    #
    # Returns global nav sections.
    #
    def get_nav_sections
      @items['/_data/navigation.yaml'][:sections]
    end

    #
    # Get the top-level section for a page, based on the global navigation.
    #
    def docs_section(path)
      path = path[1..] # remove the leading slash

      get_nav_sections.each do |section|
        section_title = section[:section_title]
        return section_title if section[:section_url] == path

        section.fetch(:section_categories, []).each do |category|
          return section_title if category[:category_url] == path
          next unless category[:docs]
          return section_title if section_exists?(category[:docs], path)
        end
      end
      nil
    end

    def section_exists?(docs, path)
      docs.each do |doc|
        return true if doc[:doc_url] == path

        sub_docs = doc[:docs]
        next unless sub_docs

        return true if section_exists?(sub_docs, path)
      end

      false
    end
  end
end

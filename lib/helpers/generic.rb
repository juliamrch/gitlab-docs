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
    # Returns a string for use in the gitlab-docs-section metatag.
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

    #
    # Generate a breadcrumb trail for a page, based on the global nav.
    #
    # Returns an array structured to fit the schema.org breadcrumbList spec.
    # See https://schema.org/BreadcrumbList
    #
    def build_breadcrumb_list(path)
      breadcrumb_list = []

      data = get_nav_sections
      crumbs = breadcrumb_trail(data, path[1..]) # remove the leading slash

      return nil if crumbs.empty?

      crumbs.each_with_index do |crumb, index|
        structured_crumb = {
          :@type => "ListItem",
          :position => index + 1,
          :name => crumb[:name]
        }

        structured_crumb[:item] = "https://docs.gitlab.com/#{crumb[:item]}" if crumb[:item] && index < crumbs.length - 1
        breadcrumb_list << structured_crumb
      end

      return nil if breadcrumb_list.empty?

      {
        '@context': "https://schema.org",
        '@type': "BreadcrumbList",
        itemListElement: breadcrumb_list
      }
    end

    #
    # Traverse the menu and return an array of breadcrumbs for a given item.
    #
    # This is used to fill in the itemListElement property in the
    # BreadcrumbList JSON-LD object, which is included in the head of each page.
    #
    def breadcrumb_trail(data, path)
      return [] if data.empty?

      data.each do |item|
        # 1st level items
        if item[:section_url] == path
          return [{ name: item[:section_title], item: item[:section_url] }]

        # 2nd level items
        elsif item.key?(:section_categories)
          result = breadcrumb_trail(item[:section_categories], path)
          next if result.empty?

          return [{ name: item[:section_title], item: item[:section_url] }] + result

        # 3rd level items
        elsif item.key?(:category_url) && item[:category_url] == path
          return [{ name: item[:category_title], item: item[:category_url] }]

        # 4th-6th level items
        elsif item.key?(:docs)
          result = breadcrumb_trail_docs(item[:docs], path)
          next if result.empty?

          return [{ name: item[:category_title], item: item[:category_url] }] + result
        end
      end

      []
    end

    #
    # Builds a breadcrumb trail for 4th-6th level menu items.
    #
    # We can use a recursive method for these since they use the same
    # property names at each level.
    #
    def breadcrumb_trail_docs(docs, path)
      return [] if docs.empty?

      docs.each do |doc|
        if doc[:doc_url] == path
          return [{ name: doc[:doc_title], item: doc[:doc_url] }]
        elsif doc.key?(:docs)
          result = breadcrumb_trail_docs(doc[:docs], path)
          next if result.empty?

          return [{ name: doc[:doc_title], item: doc[:doc_url] }] + result
        end
      end

      []
    end
  end
end

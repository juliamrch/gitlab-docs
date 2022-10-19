# frozen_string_literal: true

module Nanoc::Helpers
  module AlgoliaRank
    ###
    # Add a URL pattern and weight to CUSTOM_PAGERANKS to modify Algolia search results.
    #
    # Weights greater than DEFAULT_PAGERANK will boost a page in search results,
    # and weights below DEFAULT_PAGERANK will lower its ranking.
    #
    # The weight value appears in the "docsearch:pageRank" metatag
    # on each page that contains the URL pattern.
    #
    # For example, the "/runner/development/reviewing-gitlab-runner.html" page
    # will match "/runner/development" in CUSTOM_PAGERANKS and receive a weight of "20".
    #
    # @see https://docsearch.algolia.com/docs/record-extractor/#boost-search-results-with-pagerank
    ##
    DEFAULT_PAGERANK = 100
    CUSTOM_PAGERANKS = {
      "/ee/api" => 50,
      "/ee/development" => 20,
      "/omnibus/development" => 20,
      "/runner/development" => 20,
      "/charts/development" => 20
    }.freeze

    def algolia_rank(item)
      result = CUSTOM_PAGERANKS.keys.find { |k| item.identifier.to_s.include? k }
      return CUSTOM_PAGERANKS[result] if result

      DEFAULT_PAGERANK
    end

    ###
    # Calculate the navigation level of a given page.
    # We use this on Algolia to increase relevance of higher-level pages.
    ###
    def algolia_level(item)
      path = item.identifier.to_s
      level = path.scan("/").count
      return level -= 1 if path.include? "index.md"

      level
    end
  end
end

# frozen_string_literal: true

module Nanoc::Helpers
  module VersionsDropdown
    STABLE_VERSIONS_REGEX = %r{^\d{1,2}\.\d{1,2}$}.freeze

    #
    # Determines whether or not to display the version banner on the frontend.
    #
    # Note: We only want the banner to display on production.
    # Production is the only environment where we serve multiple versions.
    #
    def show_version_banner?
      production? && !latest?
    end

    #
    # Get online versions from the JSON file.
    #
    def get_versions
      file = File.read('./content/versions.json')
      parsed = JSON.parse(file)
      parsed[0]
    end

    #
    # Returns the site version using the branch or tag from the CI build.
    #
    def site_version
      if !ENV['CI_COMMIT_REF_NAME'].nil? && stable_version?(ENV['CI_COMMIT_REF_NAME'])
        ENV['CI_COMMIT_REF_NAME']
      else
        # If this wasn't built on CI, this is a local site that can default to the pre-release version.
        get_versions["next"]
      end
    end

    #
    # Returns the site version for Algolia DocSearch.
    #
    # For DocSearch, we need to pass "main" instead of a version number
    # in the case of the pre-release site.
    #
    def docsearch_version
      if get_versions["next"] == site_version
        ENV['CI_DEFAULT_BRANCH']
      else
        site_version
      end
    end

    #
    # Check if this site version is the latest.
    #
    # We consider two versions to be "latest":
    # 1) The main branch (CI_DEFAULT_BRANCH), which are pre-release docs for the next version.
    # 2) The most recent stable release, which is "current" in versions.json.
    #
    def latest?
      ENV['CI_COMMIT_REF_NAME'] == ENV['CI_DEFAULT_BRANCH'] || ENV['CI_COMMIT_REF_NAME'] == get_versions["current"]
    end

    #
    # Stable versions regexp
    #
    # At most two digits for major and minor numbers.
    #
    def stable_version?(version)
      version.match?(STABLE_VERSIONS_REGEX)
    end
  end
end

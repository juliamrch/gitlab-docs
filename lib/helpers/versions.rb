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
    # Returns the site version using the branch or tag from the CI build.
    #
    def site_version
      version_tag = ENV.fetch('CI_COMMIT_REF_NAME', nil)
      if !version_tag.nil? && stable_version?(version_tag)
        version_tag
      else
        # If this wasn't built on CI, this is a local site that can default to the pre-release version.
        config[:online_versions][:next]
      end
    end

    #
    # Returns the site version for Algolia DocSearch.
    #
    # For DocSearch, we need to pass "main" instead of a version number
    # in the case of the pre-release site.
    #
    def docsearch_version
      if config[:online_versions][:next] == site_version
        ENV.fetch('CI_DEFAULT_BRANCH', nil)
      else
        site_version
      end
    end

    #
    # Returns the current stable version.
    #
    def get_current_stable_version
      config[:online_versions][:current]
    end

    #
    # Check if this site version is the latest.
    #
    # We consider two versions to be "latest":
    # 1) The main branch (CI_DEFAULT_BRANCH), which are pre-release docs for the next version.
    # 2) The most recent stable release, which is "current" in versions.json.
    #
    def latest?
      ENV['CI_COMMIT_REF_NAME'] == ENV['CI_DEFAULT_BRANCH'] || ENV['CI_COMMIT_REF_NAME'] == get_current_stable_version
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

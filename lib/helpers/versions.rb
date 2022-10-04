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
    # Check if the current version is the latest.
    #
    def latest?
      file = File.read('./content/versions.json')
      parsed = JSON.parse(file)
      latest_version = parsed[0]['current']
      ENV['CI_COMMIT_REF_NAME'] == ENV['CI_DEFAULT_BRANCH'] || ENV['CI_COMMIT_REF_NAME'] == latest_version
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

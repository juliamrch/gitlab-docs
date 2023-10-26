# frozen_string_literal: true

module Nanoc::Helpers
  module VersionsDropdown
    STABLE_VERSIONS_REGEX = %r{^\d{1,2}\.\d{1,2}$}.freeze

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
    # Stable versions regexp
    #
    # At most two digits for major and minor numbers.
    #
    def stable_version?(version)
      version.match?(STABLE_VERSIONS_REGEX)
    end
  end
end

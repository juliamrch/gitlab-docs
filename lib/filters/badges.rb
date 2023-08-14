# frozen_string_literal: true

# GitLab subscription tiers and offerings badges
#
# This allows us to add visual Badges to our documentation using standard Markdown
# that will render in any markdown editor.
#
# Badges are defined in content/_data/badges.yaml.
#
# The available pattern is:
#  - `**(<TIER BADGE> <OFFERING BADGE> <STATUS BADGE>)**`
#
class BadgesFilter < Nanoc::Filter
  identifier :badges

  badge_data = YAML.load_file('content/_data/badges.yaml')
  badge_types = %w[tier offering status].freeze

  id_mapping = {}
  badge_types.each do |type|
    ids_with_given_type = badge_data["badgeIndex"].select { |item| item["type"] == type }.map { |item| item["id"].upcase }
    id_mapping[type.upcase] = ids_with_given_type.join("|")
  end

  TIERS = id_mapping["TIER"]
  OFFERINGS = id_mapping["OFFERING"]
  STATUSES = id_mapping["STATUS"]

  BADGES_HTML_PATTERN = %r{
    <strong>
    \(
    (?:
      (?:(?<tier>#{TIERS})(?:\s+(?<offering>#{OFFERINGS}))?(?:\s+(?<status>#{STATUSES}))?)  # All three badge types
      |
      (?:(?<tier>#{TIERS})(?:\s+(?<offering>#{OFFERINGS}))?)                                # Tier and offering
      |
      (?:(?<tier>#{TIERS})(?:\s+(?<status>#{STATUSES}))?)                                   # Tier and status
      |
      (?:(?<offering>#{OFFERINGS})(?:\s+(?<status>#{STATUSES}))?)                           # Offering and status
      |
      (?<tier>#{TIERS})                                                                     # Only tier
      |
      (?<offering>#{OFFERINGS})                                                             # Only offering
      |
      (?<status>#{STATUSES})                                                                # Only status
    )
    \)
    </strong>
  }x.freeze

  BADGES_MARKDOWN_PATTERN = %r{
    (?:^|[^`])
    \*\*(?:\[|\()
    (?:
      (?:(?<tier>#{TIERS})(?:\s+(?<offering>#{OFFERINGS}))?(?:\s+(?<status>#{STATUSES}))?)  # All three badge types
      |
      (?:(?<tier>#{TIERS})(?:\s+(?<offering>#{OFFERINGS}))?)                                # Tier and offering
      |
      (?:(?<tier>#{TIERS})(?:\s+(?<status>#{STATUSES}))?)                                   # Tier and status
      |
      (?:(?<offering>#{OFFERINGS})(?:\s+(?<status>#{STATUSES}))?)                           # Offering and status
      |
      (?<tier>#{TIERS})                                                                     # Only tier
      |
      (?<offering>#{OFFERINGS})                                                             # Only offering
      |
      (?<status>#{STATUSES})                                                                # Only status
    )
    (?:\]|\))\*\*
    (?:$|[^`])
  }x.freeze

  def run(content, _params = {})
    content.gsub(BADGES_HTML_PATTERN) { generate(Regexp.last_match[:tier], Regexp.last_match[:offering], Regexp.last_match[:status]) }
  end

  def run_from_markdown(content)
    content.gsub(BADGES_MARKDOWN_PATTERN) { generate(Regexp.last_match[:tier], Regexp.last_match[:offering], Regexp.last_match[:status]) }
  end

  def generate(tier, offering, status)
    badges = { tier: tier, offering: offering, status: status }
    return "" if badges.empty?

    badges_markup = badges.map do |key, value|
      next if value.nil?

      %(<span data-type="#{key}" data-value="#{value.downcase}"></span>)
    end.join

    %(<span data-component="docs-badges">#{badges_markup}</span>)
  end
end

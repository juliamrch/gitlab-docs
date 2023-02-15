# frozen_string_literal: true

# GitLab price / tiers badge
#
# This allows us to add visual Badges to our documentation using standard Markdown
# that will render in any markdown editor.
#
# The available pattern is either:
#  - `**(<BADGE_TYPE> <MODIFIER>)**` (preferred)
#  - `**[<BADGE_TYPE> <MODIFIER>]**` (deprecated)
#
# The following TIERS are supported: CORE, STARTER, PREMIUM, ULTIMATE
# The following MODIFIERS are supported: ONLY
#
# When you have ONLY as MODIFIER, it means, it applies only for on premise instances
# so we are not going to expand "STARTER" to "BRONZE" as well.
class BadgesFilter < Nanoc::Filter
  identifier :badges

  BADGES_HTML_PATTERN = %r{
    <strong>
    [\[|(]
    (?<tier>CORE|STARTER|PREMIUM|ULTIMATE|FREE|BRONZE|SILVER|GOLD)(?:\s+(?<type>ONLY|SAAS|SELF))?
    [\]|)]
    </strong>
  }x.freeze

  BADGES_MARKDOWN_PATTERN = %r{
    (?:^|[^`]) # must be start of the line or anything except backtick
    \*\*(?:\[|\()
    (?<tier>CORE|STARTER|PREMIUM|ULTIMATE|FREE|BRONZE|SILVER|GOLD)(?:\s+(?<type>ONLY|SAAS|SELF))
    ?(?:\]|\))\*\*
    (?:$|[^`]) # must end of line or anything except backtick
  }x.freeze

  def run(content, _params = {})
    content.gsub(BADGES_HTML_PATTERN) { generate(Regexp.last_match[:tier].downcase, Regexp.last_match[:type]) }
  end

  def run_from_markdown(content)
    content.gsub(BADGES_MARKDOWN_PATTERN) { generate(Regexp.last_match[:tier].downcase, Regexp.last_match[:type]) }
  end

  def generate(tier, type)
    if !type.nil?
      %(<span class="badge-trigger #{tier}-#{type.downcase}"></span>)
    else
      %(<span class="badge-trigger #{tier}"></span>)
    end
  end
end

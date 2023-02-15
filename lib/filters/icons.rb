# frozen_string_literal: true

# This allows us to add icons to our documentation using standard Markdown
#
# Usage: `**{<icon-name>, <optional-size>, <optional-class>}**`
#
#   <icon-name> - All icons in gitlab-svgs are supported: https://gitlab-org.gitlab.io/gitlab-svgs/
#   <optional-size> - Supported sizes (default: 16)
#   <optional-class> - Custom CSS class can be added for styling purposes.
#
#   Examples:
#     `**{admin}**`
#     `**{admin, 32}**`
#     `**{admin, 32, some-class}**`
#
class IconsFilter < Nanoc::Filter
  identifier :icons

  ICON_PATTERN = %r{\{\s*([\w-]+)\s*(?:,\s*(\d+))?\s*(?:,\s*([\w-]+))?\s*\}}.freeze
  ICON_HTML_PATTERN = %r{<strong>#{ICON_PATTERN}</strong>}.freeze
  ICON_MARKDOWN_PATTERN = %r{\*\*#{ICON_PATTERN}\*\*}.freeze

  def run(content, _params = {})
    content.gsub(ICON_HTML_PATTERN) { generate(Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3)) }
  end

  def run_from_markdown(content)
    content.gsub(ICON_MARKDOWN_PATTERN) { generate(Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3)) }
  end

  def generate(icon, size, css_class)
    icon(icon, size, css_class)
  end
end

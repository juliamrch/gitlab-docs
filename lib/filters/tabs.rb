# frozen_string_literal: true

class TabsFilter < Nanoc::Filter
  identifier :tabs

  TABSET_PATTERN = %r{<p>::Tabs</p>(?<tabs_wrapper>.*?)<p>::EndTabs</p>}mx.freeze
  TAB_TITLE_PATTERN = %r{<p>:::TabTitle\s(?<tab_title>.*?)</p>}mx.freeze

  def run(content, params = {})
    new_content = content.gsub(TAB_TITLE_PATTERN) { generateTitles(Regexp.last_match[:tab_title]) }
    new_content.gsub(TABSET_PATTERN) { generateWrapper(Regexp.last_match[:tabs_wrapper]) }
  end

  def generateTitles(content)
    %(<div class="tab-title">#{content}</div>)
  end

  def generateWrapper(content)
    %(<div class="js-tabs">#{content}</div>)
  end
end

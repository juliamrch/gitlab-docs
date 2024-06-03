# frozen_string_literal: true

class TabsFilter < Nanoc::Filter
  identifier :tabs

  TABSET_PATTERN = %r{<p>::Tabs</p>(?<tabs_wrapper>.*?)<p>::EndTabs</p>}mx
  TAB_TITLE_PATTERN = %r{<p>:::TabTitle\s(?<tab_title>.*?)</p>}mx

  def run(content, _params = {})
    new_content = content.gsub(TAB_TITLE_PATTERN) { generate_titles(Regexp.last_match[:tab_title]) }
    new_content.gsub(TABSET_PATTERN) { generate_wrapper(Regexp.last_match[:tabs_wrapper]) }
  end

  def generate_titles(content)
    %(<div class="tab-title">#{content}</div>)
  end

  def generate_wrapper(content)
    %(<div class="js-tabs">#{content}</div>)
  end
end

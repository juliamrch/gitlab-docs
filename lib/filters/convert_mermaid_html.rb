# frozen_string_literal: true

class ConvertMermaidHtml < Nanoc::Filter
  identifier :convert_mermaid_html

  MERMAID_HTML_PATTERN = %r{<div\ class="mermaid">(?<mermaid_content>.*?)</div>}mx.freeze

  def run(content, params = {})
    content.gsub(MERMAID_HTML_PATTERN) { generate(Regexp.last_match[:mermaid_content]) }
  end

  def generate(content)
    fixed_content = content
      .gsub('&', '&amp;')
      .gsub('<', '&lt;')
      .gsub('>', '&gt;')
      .gsub('"', '&quot;')

    %(<div class="mermaid load-mermaid">#{fixed_content}</div>)
  end
end

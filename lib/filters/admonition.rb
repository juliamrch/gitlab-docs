# frozen_string_literal: true

# Adapted from the admonition code on http://nanoc.ws/
class AdmonitionFilter < Nanoc::Filter
  identifier :admonition

  def run(content, _params = {})
    # `#dup` is necessary because `.fragment` modifies the incoming string. Ew!
    # See https://github.com/sparklemotion/nokogiri/issues/1077
    doc = Nokogiri::HTML.fragment(content.dup)
    doc.css('p').each do |para|
      content = para.inner_html
      match = content.match(%r{\A(?<type>NOTE|WARNING|FLAG|INFO|DISCLAIMER|DETAILS):\s?(?<content>.*)\Z}m)
      next unless match

      new_content = admonition(match[:type].downcase, match[:content])
      para.replace(new_content)
    end
    doc.to_s
  end
end

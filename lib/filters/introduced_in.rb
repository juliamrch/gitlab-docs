# frozen_string_literal: true

# Adapted from the admonition code on http://nanoc.ws/
class IntroducedInFilter < Nanoc::Filter
  identifier :introduced_in

  def run(content, _params = {})
    # `#dup` is necessary because `.fragment` modifies the incoming string. Ew!
    # See https://github.com/sparklemotion/nokogiri/issues/1077
    @incremental_id = 0
    doc = Nokogiri::HTML.fragment(content.dup)
    doc.css('blockquote').each do |blockquote|
      content = blockquote.inner_html
      # Searches for a blockquote with either:
      # - "deprecated <optional text> in"
      # - "introduced <optional text> in"
      # - "moved <optional text> to"
      # - "recommended <optional text> in"
      # - "removed <optional text> in"
      # - "renamed <optional text> in"
      # - "changed <optional text> in"
      # - "enabled <optional text> in"
      # ...followed by "GitLab"
      next unless content.match?(%r{(<a href="[^"]+">)?(
        introduced|
        enabled|
        (re)?moved|
        changed|
        deprecated|
        renamed|
        recommended
        )(</a>)?(.*)? (in|to).*GitLab}xmi)

      new_content = generate(content)
      blockquote.replace(new_content)
    end
    doc.to_s
  end

  def generate(content)
    @incremental_id += 1
    # If the content is a list of items, collapse the content.
    if content.match?(%r{<ul>}i)
      <<~HTML
      <div class="introduced-in mb-3">Version history
        <button class="text-expander" type="button" data-toggle="collapse" data-target="#release_version_notes_#{@incremental_id}" aria-expanded="false" aria-controls="release_version_notes_#{@incremental_id}" aria-label="Version history"></button>
        <div class="introduced-in-content collapse" id="release_version_notes_#{@incremental_id}">
          #{content}
        </div>
      </div>
      HTML
    else
      %(<div class="introduced-in">#{content}</div>)
    end
  end
end

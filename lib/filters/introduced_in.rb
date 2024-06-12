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
        added|
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
    <<~HTML
    <div class="introduced-in gl-mb-5"><strong class="history-label">History</strong>
      <button class="text-expander" type="button" data-toggle="collapse" data-target="#release_version_notes_#{@incremental_id}" aria-expanded="false" aria-controls="release_version_notes_#{@incremental_id}" aria-label="History"></button>
      <div class="introduced-in-content collapse" id="release_version_notes_#{@incremental_id}">
        #{content}
      </div>
    </div>
    HTML
  end
end

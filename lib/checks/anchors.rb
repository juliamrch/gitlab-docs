# frozen_string_literal: true

Nanoc::Check.define(:internal_anchors) do
  excluded_anchors = %w[markdown-toc offline-archives]
  output_html_filenames.each do |file|
    Gitlab::Docs::Page.new(file).links.each do |link|
      next unless link.internal?
      next unless link.to_anchor?
      next if excluded_anchors.include? link.anchor_name

      next unless link.destination_anchor_not_found?

      add_issue <<~ERROR
        Broken anchor detected: `##{link.anchor_name}`
              - source file `#{link.source_file}`
              - destination `#{link.href}`
      ERROR
    end
  end
end

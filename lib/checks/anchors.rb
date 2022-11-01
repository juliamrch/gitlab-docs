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
        Broken anchor detected!
              - source file `#{link.source_file}`
              - destination `#{link.destination_file}`
              - link `#{link.href}`
              - anchor `##{link.anchor_name}`
      ERROR
    end
  end
  add_issue "#{issues.count} offenses found!" if issues.count.positive?
end

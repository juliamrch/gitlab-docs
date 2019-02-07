Nanoc::Check.define(:internal_anchors) do
  output_html_filenames.each do |file|
    Gitlab::Docs::Page.new(file).links.each do |link|
      next unless link.internal?
      next unless link.to_anchor?
      next if link.anchor_name == 'markdown-toc'

      if link.destination_page_not_found?
        add_issue <<~ERROR
          Destination page not found!
                - link `#{link.href}`
                - source file `#{link.source_file}`
                - destination `#{link.destination_file}`
        ERROR
      elsif link.destination_anchor_not_found?
        add_issue <<~ERROR
          Broken anchor detected!
                - anchor `##{link.anchor_name}`
                - link `#{link.href}`
                - source file `#{link.source_file}`
                - destination `#{link.destination_file}`
        ERROR
      end
    end
  end

  add_issue "#{issues.count} offenses found!"
end

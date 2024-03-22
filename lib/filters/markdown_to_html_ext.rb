# frozen_string_literal: true

module Nanoc::Filters
  class MarkdownToHtmlExt < Nanoc::Filter
    identifier :md_to_html_ext

    # Convert internal URLs that link to `.md` files to instead link to
    # { }`.html` files since that's what Nanoc actually serves.
    def run(content, _params = {})
      content.gsub(%r{href="(\S*.md\S*)"}) do |result| # Fetch all links in the HTML Document
        if %r{^href="http}.match(result).nil? # Check if link is internal
          result.gsub!(%r{\.md}, '.html') # Replace the extension if link is internal
        end

        if %r{_index.html}.match?(result) # If linking to _index.html
          result.gsub!('_index', 'index') # Replace _index with index
        end

        result
      end
    end
  end
end

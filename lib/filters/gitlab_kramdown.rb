# frozen_string_literal: true

module Nanoc::Filters
  # @api private
  class GitLabKramdown < Nanoc::Filter
    requires 'kramdown'

    identifier :gitlab_kramdown

    TOC_PATCH = <<~PATCH
      * TOC
      {:toc}

    PATCH

    PRODUCT_SUFFIX = /-(core|starter|premium|ultimate)(-only)?/.freeze

    # Runs the content through [GitLab Kramdown](https://gitlab.com/brodock/gitlab_kramdown).
    # Parameters passed to this filter will be passed on to Kramdown.
    #
    # @param [String] raw_content The content to filter
    #
    # @return [String] The filtered content
    def run(raw_content, params = {})
      params = params.dup
      warning_filters = params.delete(:warning_filters)
      with_toc = params.delete(:with_toc)

      content = with_toc ? TOC_PATCH + raw_content : raw_content
      document = ::Kramdown::Document.new(content, params)

      update_anchors_with_product_suffixes!(document.root.children)

      if warning_filters
        r = Regexp.union(warning_filters)
        warnings = document.warnings.reject { |warning| r =~ warning }
      else
        warnings = document.warnings
      end

      if warnings.any?
        $stderr.puts "\nkramdown warning(s) for #{@item_rep.inspect}"
        warnings.each do |warning|
          $stderr.puts "  #{warning}"
        end
      end

      document.to_html
    end

    private

    def update_anchors_with_product_suffixes!(elements)
      headers = find_type_elements(:header, elements)

      headers.each do |header|
        next unless header.attr['id'].match(PRODUCT_SUFFIX)

        remove_product_suffix!(header, 'id')

        link = find_type_elements(:a, header.children).first

        remove_product_suffix!(link, 'href') if link
      end
    end

    def remove_product_suffix!(element, attr)
      element.attr[attr] = element.attr[attr].gsub(PRODUCT_SUFFIX, '')
    end

    def find_type_elements(type, elements)
      results = []

      elements.each do |e|
        results.push(e) if type == e.type

        unless e.children.empty?
          results.concat(find_type_elements(type, e.children))
        end
      end

      results
    end
  end
end

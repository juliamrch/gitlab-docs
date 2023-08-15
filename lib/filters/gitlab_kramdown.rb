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

    # Runs the content through [GitLab Kramdown](https://gitlab.com/gitlab-org/ruby/gems/gitlab_kramdown).
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
        warnings = document.warnings.grep_v(r)
      else
        warnings = document.warnings
      end

      if warnings.any?
        warn "\nkramdown warning(s) for #{@item_rep.inspect}"
        warnings.each do |warning|
          warn "  #{warning}"
        end
      end

      document.to_html
    end

    private

    def update_anchors_with_product_suffixes!(elements)
      headers = find_type_elements(:header, elements)

      headers.each do |header|
        # Badges, and only badges, are contained in bold text in headers.
        # We need to drop these from header IDs and anchor links.
        badges = find_type_elements(:strong, header.children).first
        next unless badges && badges.children.first.value

        badges_suffix = badges.children.first.value.gsub(%r{\(([\w\s]+)\)}, '\1').gsub(%r{\s+}, '-').downcase

        remove_product_suffix!(header, badges_suffix, 'id')
        link = find_type_elements(:a, header.children).first
        remove_product_suffix!(link, badges_suffix, 'href') if link
      end
    end

    def remove_product_suffix!(element, badges_suffix, attr)
      element.attr[attr] = element.attr[attr].gsub(%r{#{Regexp.escape(badges_suffix)}\z}, "").gsub(%r{-$}, "")
    end

    def find_type_elements(type, elements)
      results = []

      elements.each do |e|
        results.push(e) if type == e.type

        e.children.empty? unless results.concat(find_type_elements(type, e.children))
      end

      results
    end
  end
end

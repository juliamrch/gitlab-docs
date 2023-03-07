# frozen_string_literal: true

require_relative '../helpers/icons_helper'

module Gitlab
  class Navigation
    include Nanoc::Helpers::IconsHelper

    def initialize(items, item)
      @items = items
      @item = item
    end

    def nav_items
      @nav_items ||= items["/_data/navigation.yaml"]
    end

    def element_href(element)
      "/#{element.url}"
    end

    def show_element?(element)
      item.path == "/#{element.url}"
    end

    def id_for(element)
      element.title.gsub(%r{[\s/()]}, '')
    end

    def children
      @children ||= nav_items.fetch(:sections, []).map { |section| Section.new(section) }
    end

    private

    attr_reader :items, :item

    def allowed_link?(link)
      link.start_with?('ee/', 'http')
    end

    def dir
      @dir ||= item.identifier.to_s[%r{(?<=/)[^/]+}]
    end
  end
end

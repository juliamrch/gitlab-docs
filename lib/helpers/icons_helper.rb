# frozen_string_literal: true

require 'json'

module Nanoc::Helpers
  module IconsHelper
    extend self

    ICONS_SVG = '/assets/images/icons.svg' unless const_defined?(:ICONS_SVG)

    unless const_defined?(:GITLAB_SVGS_MAPPING)
      GITLAB_SVGS_MAPPING = {
        'bulb' => 'tip',
        'information-o' => 'note',
        'warning' => 'caution'
      }.freeze
    end

    def icon(icon_name, size = nil, css_class = nil)
      unless known_sprites.include?(icon_name)
        exception = ArgumentError.new("#{icon_name} is not a known icon in @gitlab-org/gitlab-svg. Contact the Technical Writing team for assistance.")
        raise exception
      end

      svg_class = [
        'gl-icon',
        'ml-1',
        'mr-1',
        "s#{size || 16}",
        *css_class
      ].join(' ')

      # https://css-tricks.com/svg-title-vs-html-title-attribute/
      %(<svg role="img" aria-label="#{GITLAB_SVGS_MAPPING[icon_name]}" class="#{svg_class}"><use href="#{ICONS_SVG}##{icon_name}" /> <title> #{GITLAB_SVGS_MAPPING[icon_name]} </title> </svg>)
    end

    private

    def read_file(path)
      root = File.expand_path('../../', __dir__)
      File.read("#{root}/#{path}")
    end

    def known_sprites
      @known_sprites ||= JSON.parse(read_file('node_modules/@gitlab/svgs/dist/icons.json'))['icons']
    end
  end
end

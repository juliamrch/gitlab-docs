# frozen_string_literal: true

module Nanoc::Helpers
  module Blueprints
    BLUEPRINTS_PATH = '/ee/architecture/blueprints/*/index.md'.freeze

    def all_blueprints
      blueprints = @items.find_all(BLUEPRINTS_PATH).sort_by do |i|
        blueprint_creation_date(i)
      end

      blueprints.reverse
    end

    def author_link(author)
      username = author.tr('@', '')
      link_to("@#{username}", "https://gitlab.com/#{username}")
    end

    def blueprint_creation_date(blueprint)
      blueprint[:'creation-date'].nil? ? '-' : Time.parse(blueprint[:'creation-date'].to_s).strftime('%Y-%m-%d')
    end

    # TODO: this is generic, should live elsewhere
    def gl_label(label)
      return if label.nil?

      scope, text = label.tr('~', '').split('::')
      is_scoped = !text.nil?

      %(
        <span class="gl-label #{is_scoped ? 'gl-label-scoped' : ''} #{scope}">
          <span class="gl-label-text">#{scope}</span>
          #{%(<span class="gl-label-text-scoped">#{text}</span>) if is_scoped}
        </span>
      )
    end
  end
end

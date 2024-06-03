# frozen_string_literal: true

module Gitlab
  module Docs
    module Nanoc
      def self.config
        @config ||= YAML.safe_load_file('nanoc.yaml')
      end

      def self.output_dir
        config.fetch('output_dir')
      end
    end
  end
end

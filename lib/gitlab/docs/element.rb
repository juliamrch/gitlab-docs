# frozen_string_literal: true

require 'cgi'

module Gitlab
  module Docs
    class Element
      def self.decode(name)
        return if name.to_s.empty?

        CGI.unescape(name)
      end

      def initialize(name, attributes)
        @name = name
        @attributes = attributes
      end

      def link?
        @name == 'a' && !href.to_s.empty?
      end

      def has_id?
        !id.to_s.empty?
      end

      def href
        @href ||= self.class.decode(attribute('href'))
      end

      def id
        @id ||= attribute('id')&.downcase
      end

      private

      def attribute(name)
        @attributes.to_a
          .find { |attr| attr.first == name }
          .to_a.last
      end
    end
  end
end

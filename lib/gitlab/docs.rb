# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'nanoc'

module Gitlab
  module Docs
    autoload :Document, 'docs/document'
    autoload :Element, 'docs/element'
    autoload :Link, 'docs/link'
    autoload :Page, 'docs/page'
    autoload :Nanoc, 'docs/nanoc'
  end
end

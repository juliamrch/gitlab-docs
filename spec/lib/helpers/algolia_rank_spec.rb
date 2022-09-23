# frozen_string_literal: true

require 'spec_helper'
require 'nanoc'
require 'helpers/algolia_rank'

RSpec.describe Nanoc::Helpers::AlgoliaRank do
    let(:mock_class) { Class.new { extend Nanoc::Helpers::AlgoliaRank } }
    let(:identifier) { "/runner/development/reviewing-gitlab-runner.html" }

    let(:mock_item) do
      item = Struct.new(:identifier)
      item.new(identifier)
    end

    subject { mock_class.algolia_rank(mock_item) }

    describe '#algolia_rank' do
      using RSpec::Parameterized::TableSyntax

      where(:url_pattern, :identifier, :weight) do
        "/ee/api"             | "/ee/api/openapi/openapi_interactive.html"              | 50
        "/runner/development" | "/runner/development/reviewing-gitlab-runner.html"      | 20
        "/ee/development"     | "/ee/development/documentation/graphql_styleguide.html" | 20
        ""                    | "/ee/install/installation.html"                         | 100
      end

      with_them do
        it 'returns correct weight for matched identifier' do
          expect(subject).to eq(weight)
        end
      end

    end
end

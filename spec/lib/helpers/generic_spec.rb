# frozen_string_literal: true

require 'spec_helper'
require 'nanoc'
require 'helpers/generic'

RSpec.describe Nanoc::Helpers::Generic do
  let(:mock_class) { Class.new { extend Nanoc::Helpers::Generic } }
  let(:path) { "ee/user/project/code_intelligence.html" }
  let(:mock_item) do
    item = Struct.new(:path)
    item.new(path)
  end

  subject { mock_class.docs_section(mock_item.path.to_s) }

  describe '#docs_section' do
    using RSpec::Parameterized::TableSyntax

    where(:path, :expected_section_title) do
      "/ee/tutorials/" | "Learn GitLab with tutorials"
      "/ee/topics/set_up_organization.html" | "Use GitLab"
      "/ee/user/project/autocomplete_characters.html" | "Use GitLab"
      "/ee/policy/alpha-beta-support.html" | "Manage GitLab subscription"
      "/updog.html" | nil
    end

    before do
      mock_items = { '/_data/navigation.yaml' => YAML.load_file('spec/lib/fixtures/navigation-mock.yaml', symbolize_names: true) }
      mock_sections = mock_items['/_data/navigation.yaml'][:sections]
      allow(mock_class).to receive(:get_nav_sections).and_return(mock_sections)
    end

    with_them do
      it "returns the section title for the given path" do
        expect(subject).to eq(expected_section_title)
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

require 'gitlab/navigation'
require 'gitlab/navigation/section'

describe Gitlab::Navigation do
  subject(:navigation) { described_class.new(items, item) }

  let(:item) { instance_double(Nanoc::Core::CompilationItemView, path: '/omnibus/user/README.html', identifier: instance_double(Nanoc::Core::Identifier, to_s: '/omnibus/user/README.md')) }
  let(:items) do
    {
      '/_data/navigation.yaml' => { sections: [Gitlab::Navigation::Section.new(section_title: 'Default Section')] }
    }
  end

  describe '#nav_items' do
    subject { navigation.nav_items }

    context 'when yaml configuration for project does not exist' do
      let(:item) { instance_double(Nanoc::Core::CompilationItemView, path: '/ee/user/README.html', identifier: instance_double(Nanoc::Core::Identifier, to_s: '/ee/user/README.md')) }

      it 'returns default sections' do
        sections = subject[:sections]
        section = sections.first

        expect(section.title).to eq('Default Section')
      end
    end
  end

  describe '#element_href' do
    subject { navigation.element_href(element) }

    let(:element) { Gitlab::Navigation::Section.new(section_url: url) }
    let(:url) { 'omnibus/user/README.html' }

    it { is_expected.to eq('/omnibus/user/README.html') }

    context 'when yaml configuration for project does not exist' do
      let(:item) { instance_double(Nanoc::Core::CompilationItemView, path: '/ee/user/README.html', identifier: instance_double(Nanoc::Core::Identifier, to_s: '/ee/user/README.md')) }

      it { is_expected.to eq('/omnibus/user/README.html') }
    end
  end

  describe '#show_element?' do
    subject { navigation.show_element?(element) }

    let(:element) { Gitlab::Navigation::Section.new(section_url: url) }
    let(:url) { 'omnibus/user/README.html' }

    it { is_expected.to be_truthy }

    context 'when url does not match item path' do
      let(:url) { 'project/README.html' }

      it { is_expected.to be_falsey }
    end
  end

  describe '#id_for' do
    subject { navigation.id_for(element) }

    let(:element) { Gitlab::Navigation::Section.new(section_title: 'Section Example') }

    it { is_expected.to eq 'SectionExample' }
  end
end

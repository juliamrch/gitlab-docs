# frozen_string_literal: true

require 'spec_helper'
require 'gitlab/navigation/section'
require 'gitlab/navigation/category'

describe Gitlab::Navigation::Section do
  subject(:section) { described_class.new(element) }

  let(:element) do
    {
      section_title: title,
      section_url: url,
      ee_only: ee_only,
      ee_tier: ee_tier,
      section_categories: categories
    }
  end

  let(:title) { 'Title' }
  let(:url) { 'README.html' }
  let(:ee_only) { true }
  let(:ee_tier) { 'GitLab Premium' }
  let(:categories) { [{ category_title: 'Category Title' }] }

  describe '#title' do
    subject { section.title }

    it { is_expected.to eq(title) }
  end

  describe '#url' do
    subject { section.url }

    it { is_expected.to eq(url) }
  end

  describe '#ee_only?' do
    subject { section.ee_only? }

    it { is_expected.to eq(ee_only) }
  end

  describe '#ee_tier' do
    subject { section.ee_tier }

    it { is_expected.to eq(ee_tier) }
  end

  describe '#has_children?' do
    subject { section.has_children? }

    it { is_expected.to be_truthy }

    context 'when categories are empty' do
      let(:categories) { [] }

      it { is_expected.to be_falsey }
    end
  end

  describe '#children' do
    subject(:section_children) { section.children }

    it 'returns a list of children' do
      expect(section_children.first.title).to eq('Category Title')
    end

    context 'when categories are empty' do
      let(:categories) { [] }

      it { is_expected.to eq([]) }
    end
  end
end

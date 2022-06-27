# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Docs::Link do
  let(:page) { instance_double(Gitlab::Docs::Page) }
  let(:href) { '../some/page.html#some-anchor' }

  subject { described_class.new(href, page) }

  describe '#to_anchor?' do
    context 'when link contains anchor name' do
      let(:href) { '../some/page.html' }

      it { is_expected.not_to be_to_anchor }
    end

    context 'when link does not contain anchor name' do
      let(:href) { '../some/page.html#some-anchor' }

      it { is_expected.to be_to_anchor }
    end

    context 'when link contains an empty anchor' do
      let(:href) { '../some/page.html#' }

      it { is_expected.not_to be_to_anchor }
    end
  end

  describe '#internal_anchor?' do
    context 'when link contains internal anchor name' do
      let(:href) { '#some-internal-anchor' }

      it { is_expected.to be_internal_anchor }
    end

    context 'when link does not contain internal anchor' do
      let(:href) { '../some/page.html#some-anchor' }

      it { is_expected.not_to be_internal_anchor }
    end
  end

  describe '#internal?' do
    context 'when link is an external link' do
      let(:href) { 'https://gitlab.com/some/page.html' }

      it { is_expected.not_to be_internal }
    end

    context 'when link is an internal link' do
      let(:href) { '../some/page.html' }

      it { is_expected.to be_internal }
    end
  end

  describe '#absolute_path' do
    before do
      allow(page).to receive(:directory).and_return('/my/path')
      allow(Gitlab::Docs::Nanoc).to receive(:output_dir).and_return('/nanoc')
    end

    context 'when link is an external link' do
      let(:href) { 'https://gitlab.com/some/page.html' }

      it 'raises an error' do
        expect { subject.absolute_path }.to raise_error(RuntimeError)
      end
    end

    context 'when link is relative' do
      let(:href) { '../some/page.html' }

      it 'expands relative link' do
        expect(subject.absolute_path).to eq '/my/some/page.html'
      end
    end

    context 'when link is absolute' do
      let(:href) { '/some/page.html' }

      it 'expands absolute path' do
        expect(subject.absolute_path).to eq '/nanoc/some/page.html'
      end
    end
  end

  describe '#destination_page' do
    context 'when the link is an internal link' do
      let(:href) { '#some-anchor' }

      it 'returns the page it is assigned by itself' do
        expect(subject.destination_page).to eq page
      end
    end

    context 'when the link is an external link' do
      let(:href) { '../some/page.html#my-anchor' }
      let(:destination) { instance_double(Gitlab::Docs::Page) }

      before do
        allow(page).to receive(:directory).and_return('/my/docs/page')
      end

      it 'builds a new page' do
        expect(Gitlab::Docs::Page).to receive(:build)
          .with('/my/docs/some/page.html')
          .and_return(destination)

        expect(subject.destination_page).to eq destination
      end
    end
  end

  describe '#source_file' do
    it 'returns page file' do
      expect(page).to receive(:file)

      subject.source_file
    end
  end

  describe '#destination_page_not_found?' do
    before do
      allow(page).to receive(:directory).and_return('/my/dir')
      allow(subject).to receive(:destination_file)
        .and_return(instance_double(Gitlab::Docs::Page, exists?: false))
    end

    it 'returns false if page does not exist' do
      expect(subject.destination_page_not_found?).to be true
    end
  end

  describe '#destination_anchor_not_found?' do
    before do
      allow(page).to receive(:directory).and_return('/my/dir')
      allow(subject).to receive(:destination_file)
        .and_return(instance_double(Gitlab::Docs::Page, has_anchor?: false))
    end

    it 'returns false if anchor does not exist' do
      expect(subject.destination_anchor_not_found?).to be true
    end
  end
end

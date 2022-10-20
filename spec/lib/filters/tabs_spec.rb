require 'spec_helper'

require 'filters/tabs'

describe TabsFilter do
  describe '#run' do
    let(:content) { nil }

    subject(:run) { described_class.new.run(content) }

    context 'when Tab title' do
      let(:content) { '<p>:::TabTitle Cats</p>' }

      it 'returns correct HTML' do
        expect(run).to eq('<div class="tab-title">Cats</div>')
      end
    end

    context 'when Tab wrapper' do
      let(:content) { '<p>::Tabs</p>Tabs content<p>::EndTabs</p>' }

      it 'returns correct HTML' do
        expect(run).to eq("<div class=\"js-tabs\">Tabs content</div>")
      end
    end
  end
end

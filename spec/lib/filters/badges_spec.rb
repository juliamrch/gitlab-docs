require 'spec_helper'

require 'filters/badges'

describe BadgesFilter do
  describe '#run' do
    let(:content) { nil }

    subject(:run) { described_class.new.run(content) }

    context 'when <strong>(FREE)</strong> badge' do
      let(:content) { '<strong>(FREE)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span data-component="docs-badges"><span data-type="tier" data-value="free"></span></span>')
      end
    end

    context 'when <strong>(FREE SELF)</strong> badge' do
      let(:content) { '<strong>(FREE SELF)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span data-component="docs-badges"><span data-type="tier" data-value="free"></span><span data-type="offering" data-value="self"></span></span>')
      end
    end

    context 'when <strong>(FREE EXPERIMENT)</strong> badge' do
      let(:content) { '<strong>(FREE EXPERIMENT)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span data-component="docs-badges"><span data-type="tier" data-value="free"></span><span data-type="status" data-value="experiment"></span></span>')
      end
    end

    context 'when <strong>(SAAS EXPERIMENT)</strong> badge' do
      let(:content) { '<strong>(SAAS EXPERIMENT)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span data-component="docs-badges"><span data-type="offering" data-value="saas"></span><span data-type="status" data-value="experiment"></span></span>')
      end
    end

    context 'when <strong>(BETA)</strong> badge' do
      let(:content) { '<strong>(BETA)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span data-component="docs-badges"><span data-type="status" data-value="beta"></span></span>')
      end
    end
  end

  describe '#run_from_markdown' do
    let(:content) { nil }

    subject(:run_from_markdown) { described_class.new.run_from_markdown(content) }

    context 'when **(FREE)** badge' do
      let(:content) { '**(FREE)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span data-component="docs-badges"><span data-type="tier" data-value="free"></span></span>')
      end
    end

    context 'when **(FREE SELF)** badge' do
      let(:content) { '**(FREE SELF)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span data-component="docs-badges"><span data-type="tier" data-value="free"></span><span data-type="offering" data-value="self"></span></span>')
      end
    end

    context 'when **(FREE EXPERIMENT)** badge' do
      let(:content) { '**(FREE EXPERIMENT)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span data-component="docs-badges"><span data-type="tier" data-value="free"></span><span data-type="status" data-value="experiment"></span></span>')
      end
    end

    context 'when **(SAAS EXPERIMENT)** badge' do
      let(:content) { '**(SAAS EXPERIMENT)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span data-component="docs-badges"><span data-type="offering" data-value="saas"></span><span data-type="status" data-value="experiment"></span></span>')
      end
    end

    context 'when **(BETA)** badge' do
      let(:content) { '**(BETA)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span data-component="docs-badges"><span data-type="status" data-value="beta"></span></span>')
      end
    end
  end
end

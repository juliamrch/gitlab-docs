require 'spec_helper'

require 'filters/badges'

describe BadgesFilter do
  describe '#run' do
    let(:content) { nil }

    subject(:run) { described_class.new.run(content) }

    context 'when <strong>(FREE)</strong> badge' do
      let(:content) { '<strong>(FREE)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span class="badge-trigger free"></span>')
      end
    end

    context 'when <strong>(PREMIUM)</strong> badge' do
      let(:content) { '<strong>(PREMIUM)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span class="badge-trigger premium"></span>')
      end
    end

    context 'when <strong>(ULTIMATE)</strong> badge' do
      let(:content) { '<strong>(ULTIMATE)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span class="badge-trigger ultimate"></span>')
      end
    end

    context 'when <strong>(FREE SELF)</strong> badge' do
      let(:content) { '<strong>(FREE SELF)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span class="badge-trigger free-self"></span>')
      end
    end

    context 'when <strong>(PREMIUM SELF)</strong> badge' do
      let(:content) { '<strong>(PREMIUM SELF)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span class="badge-trigger premium-self"></span>')
      end
    end

    context 'when <strong>(ULTIMATE SELF)</strong> badge' do
      let(:content) { '<strong>(ULTIMATE SELF)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span class="badge-trigger ultimate-self"></span>')
      end
    end

    context 'when <strong>(FREE SAAS)</strong> badge' do
      let(:content) { '<strong>(FREE SAAS)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span class="badge-trigger free-saas"></span>')
      end
    end

    context 'when <strong>(PREMIUM SAAS)</strong> badge' do
      let(:content) { '<strong>(PREMIUM SAAS)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span class="badge-trigger premium-saas"></span>')
      end
    end

    context 'when <strong>(ULTIMATE SAAS)</strong> badge' do
      let(:content) { '<strong>(ULTIMATE SAAS)</strong>' }

      it 'returns correct HTML' do
        expect(run).to eq('<span class="badge-trigger ultimate-saas"></span>')
      end
    end
  end

  describe '#run_from_markdown' do
    let(:content) { nil }

    subject(:run_from_markdown) { described_class.new.run_from_markdown(content) }

    context 'when **(FREE)** badge' do
      let(:content) { '**(FREE)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span class="badge-trigger free"></span>')
      end
    end

    context 'when **(PREMIUM)** badge' do
      let(:content) { '**(PREMIUM)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span class="badge-trigger premium"></span>')
      end
    end

    context 'when **(ULTIMATE)** badge' do
      let(:content) { '**(ULTIMATE)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span class="badge-trigger ultimate"></span>')
      end
    end

    context 'when **(FREE SELF)** badge' do
      let(:content) { '**(FREE SELF)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span class="badge-trigger free-self"></span>')
      end
    end

    context 'when **(PREMIUM SELF)** badge' do
      let(:content) { '**(PREMIUM SELF)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span class="badge-trigger premium-self"></span>')
      end
    end

    context 'when **(ULTIMATE SELF)** badge' do
      let(:content) { '**(ULTIMATE SELF)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span class="badge-trigger ultimate-self"></span>')
      end
    end

    context 'when **(FREE SAAS)** badge' do
      let(:content) { '**(FREE SAAS)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span class="badge-trigger free-saas"></span>')
      end
    end

    context 'when **(PREMIUM SAAS)** badge' do
      let(:content) { '**(PREMIUM SAAS)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span class="badge-trigger premium-saas"></span>')
      end
    end

    context 'when **(ULTIMATE SAAS)** badge' do
      let(:content) { '**(ULTIMATE SAAS)**' }

      it 'returns correct HTML' do
        expect(run_from_markdown).to eq('<span class="badge-trigger ultimate-saas"></span>')
      end
    end
  end
end

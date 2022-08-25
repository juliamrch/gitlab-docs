# frozen_string_literal: true

require './lib/tasks/task_helpers'

describe TaskHelpers do
  describe '#chart_version' do
    let(:gitlab_version) { nil }

    subject(:chart_version) { described_class.new.chart_version(gitlab_version) }

    context 'when GitLab version is 15' do
      let(:gitlab_version) { '15.0' }

      it 'returns charts version 6.0' do
        expect(chart_version).to eq('6.0')
      end
    end
  end
end

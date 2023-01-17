# frozen_string_literal: true

require './lib/tasks/task_helpers'

describe TaskHelpers do
  describe '#project_root' do
    it 'returns project checkout root' do
      expect(
        described_class.new.project_root
      ).to eq(
        File.expand_path(File.join(__dir__, '/../..'))
      )
    end
  end

  describe '#charts_stable_branch' do
    subject(:charts_stable_branch) { described_class.new.charts_stable_branch }

    context 'when GitLab version is 15-0-stable' do
      ENV['CI_COMMIT_REF_NAME'] = '15.0'

      let(:stable_branch_name) { '15-0-stable' }

      it 'returns charts branch 6-0-stable' do
        expect(charts_stable_branch).to eq('6-0-stable')
      end
    end
  end
end

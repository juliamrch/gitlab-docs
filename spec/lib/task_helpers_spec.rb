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

  describe '#current_milestone' do
    let(:task_helpers) { described_class.new }

    context 'when the date is 2023-10' do
      it 'returns GitLab version 16.5' do
        expect(task_helpers.current_milestone('2023-10')).to eq('16.5')
      end
    end

    context 'when the date is 2025-05' do
      it 'returns GitLab version 18.0' do
        expect(task_helpers.current_milestone('2025-05')).to eq('18.0')
      end
    end

    context 'when the date is 2084-11' do
      it 'returns nil' do
        expect(task_helpers.current_milestone('2084-11')).to be_nil
      end
    end
  end
end

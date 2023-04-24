# frozen_string_literal: true

require 'spec_helper'

require_relative '../../lib/release'

RSpec.describe Release do
  let(:version) { 99.99 }
  let(:dry_run) { nil }
  let(:task_helpers) { TaskHelpers.new }

  subject { described_class.new(version: version, dry_run: dry_run) }

  before do
    allow(TaskHelpers).to receive(:new).and_return(task_helpers)
  end

  describe '#single' do
    context 'when in DRY_RUN mode' do
      let(:dry_run) { true }

      it 'does not push the branch' do
        expect_info("DRY RUN: Not stashing local changes.")
        expect_info("DRY RUN: Not checking out main branch and pulling updates.")
        expect_info("DRY RUN: Not creating branch #{version}.")
        expect_info("DRY RUN: Not creating file #{version}.Dockerfile.")
        expect_info("DRY RUN: Not adding file #{version}.Dockerfile to branch #{version} or commiting changes.")
        expect_info("DRY RUN: Not pushing branch #{version}.")

        subject.single
      end
    end

    context 'when not in DRY_RUN mode' do
      let(:dry_run) { false }

      it 'pushes the branch' do
        allow(task_helpers).to receive(:info).with('gitlab-docs', any_args)

        allow(task_helpers).to receive(:git_workdir_dirty?).and_return(true)

        expect_exec_cmd("git stash -u")
        expect_exec_cmd("git checkout main")
        expect_exec_cmd("git pull origin main")
        expect_exec_cmd("git checkout -b #{version}")

        single_dockerfile_double = instance_double(Pathname, read: 'ARG VER')
        expect(Pathname).to receive(:new).with('dockerfiles/single.Dockerfile').and_return(single_dockerfile_double)

        dockerfile_double = instance_double(Pathname, exist?: false)
        expect(Pathname).to receive(:new).with("#{version}.Dockerfile").and_return(dockerfile_double)
        expect(dockerfile_double).to receive(:open).with('w').and_yield(dockerfile_double)
        expect(dockerfile_double).to receive(:write).with("ARG VER=#{version}")

        expect_exec_cmd("git add #{version}.Dockerfile")
        expect_exec_cmd("git commit -m 'Release cut #{version}'")

        expect_exec_cmd("git push origin #{version}")

        subject.single
      end
    end
  end

  describe '#update_versions_dropdown' do
    context 'when in DRY_RUN mode' do
      let(:dry_run) { true }

      it 'does not update the versions dropdown' do
        expect_info("DRY RUN: Not updating the version dropdown...")
        expect(File).not_to receive(:write)

        subject.update_versions_dropdown
      end
    end

    context 'when not in DRY_RUN mode' do
      let(:dry_run) { false }

      it 'updates content/versions.json' do
        expected_json = [{ "next" => "16.0", "current" => "15.11", "last_minor" => ["15.10", "15.9"], "last_major" => ["14.10", "13.12"] }]

        expect_info("Updating content/versions.json...")
        expect(File).to receive(:write).with('content/versions.json', JSON.pretty_generate(expected_json))

        subject.update_versions_dropdown
      end
    end
  end

  def expect_info(msg)
    expect(task_helpers).to receive(:info).with('gitlab-docs', msg)
  end

  def expect_exec_cmd(cmd)
    expect(subject).to receive(:exec_cmd).with(cmd)
  end
end

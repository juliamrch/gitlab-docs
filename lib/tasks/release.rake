# frozen_string_literal: true

require './lib/tasks/task_helpers'
require 'fileutils'
require 'pathname'

task_helpers = TaskHelpers.new
DRY_RUN = ENV['DRY_RUN'] == 'true'

namespace :release do
  desc 'Creates a single release archive'
  task :single, :version do
    require "highline/import"
    version = task_helpers.current_milestone

    # Disable lefthook because it causes PATH errors
    # https://docs.gitlab.com/ee/development/contributing/style_guides.html#disable-lefthook-temporarily
    ENV['LEFTHOOK'] = '0'

    abort("\n#{TaskHelpers::COLOR_CODE_RED}ERROR: Rake aborted! Local branch already exists. Run `git branch --delete --force #{version}` and rerun the task.#{TaskHelpers::COLOR_CODE_RESET}") \
      if task_helpers.local_branch_exist?(version)

    if DRY_RUN
      TaskHelpers.info("gitlab-docs", "DRY RUN: Not stashing local changes.")
    else
      TaskHelpers.info("gitlab-docs", "Stashing local changes...")
      `git stash -u` if task_helpers.git_workdir_dirty?
    end

    if DRY_RUN
      TaskHelpers.info("gitlab-docs", "DRY RUN: Not checking out main branch and pulling updates.")
    else
      TaskHelpers.info("gitlab-docs", "Checking out main branch and pulling updates...")
      `git checkout main`
      `git pull origin main`
    end

    if DRY_RUN
      TaskHelpers.info("gitlab-docs", "DRY RUN: Not creating branch #{version}.")
    else
      TaskHelpers.info("gitlab-docs", "Creating branch #{version}...")
      `git checkout -b #{version}`
    end

    dockerfile = Pathname.new("#{version}.Dockerfile")
    single_dockerfile = Pathname.new('dockerfiles/single.Dockerfile')

    if DRY_RUN
      TaskHelpers.info("gitlab-docs", "DRY RUN: Not creating file #{dockerfile}.")
    elsif File.exist?(dockerfile) && ask("#{dockerfile} already exists. Do you want to overwrite?", %w[y n]) == 'n'
      abort('rake aborted!')
    else
      TaskHelpers.info("gitlab-docs", "Creating file #{dockerfile}...")
      dockerfile.open('w') do |post|
        post.write(single_dockerfile.read.gsub('ARG VER', "ARG VER=#{version}"))
      end
    end

    if DRY_RUN
      TaskHelpers.info("gitlab-docs", "DRY RUN: Not adding file #{dockerfile} to branch #{version} or commiting changes.")
    else
      TaskHelpers.info("gitlab-docs", "Adding file #{dockerfile} and commiting changes to branch #{version}...")
      `git add #{version}.Dockerfile`
      `git commit -m 'Release cut #{version}'`
    end

    if DRY_RUN
      TaskHelpers.info("gitlab-docs", "DRY RUN: Not pushing branch #{version}.")
    else
      TaskHelpers.info("gitlab-docs", "Pushing branch #{version}. Don't create a merge request...")
      `git push origin #{version}`
    end
  end
end

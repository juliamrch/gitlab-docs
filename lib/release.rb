# frozen_string_literal: true

require_relative 'tasks/task_helpers'

require 'fileutils'
require 'pathname'

class Release
  CURRENT_RELEASE_DATE = Date.today.strftime("%Y-%m-22")
  NEXT_RELEASE_DATE = (Date.today >> 1).strftime("%Y-%m-22")
  PREVIOUS_RELEASE_DATE = (Date.today << 1).strftime("%Y-%m-22")
  PREVIOUS_PREVIOUS_RELEASE_DATE = (Date.today << 2).strftime("%Y-%m-22")

  ExplicitError = Class.new(StandardError)

  def initialize(version: nil, dry_run: ENV['DRY_RUN'] == 'true')
    @version = version || task_helpers.milestone(CURRENT_RELEASE_DATE)
    @dry_run = dry_run
  end

  def single
    # Disable lefthook because it causes PATH errors
    # https://docs.gitlab.com/ee/development/contributing/style_guides.html#disable-lefthook-temporarily
    ENV['LEFTHOOK'] = '0'

    raise ExplicitError, "Local branch already exists. Run `git branch --delete --force #{version}` and rerun the task." if !dry_run && task_helpers.local_branch_exist?(version)
    raise ExplicitError, "'#{dockerfile}' already exists. Run `rm #{dockerfile}` and rerun the task." if dockerfile.exist?

    stash_changes
    checkout_main_and_update
    create_branch_for_version
    create_dockerfile
    commit_dockerfile
    git_push_branch
  end

  def update_versions_dropdown
    if dry_run
      info("DRY RUN: Not updating the version dropdown...")
    else
      current_version = task_helpers.milestone(CURRENT_RELEASE_DATE)
      next_version = task_helpers.milestone(NEXT_RELEASE_DATE)
      previous_version = task_helpers.milestone(PREVIOUS_RELEASE_DATE)
      previous_previous_version = task_helpers.milestone(PREVIOUS_PREVIOUS_RELEASE_DATE)

      dropdown_json = JSON.load_file!('content/versions.json')
      dropdown_json.first.merge!(
        'next' => next_version,
        'current' => current_version,
        'last_minor' => [previous_version, previous_previous_version]
      )

      info("Updating content/versions.json...")
      File.write('content/versions.json', JSON.pretty_generate(dropdown_json))
    end
  end

  private

  attr_reader :version, :dry_run

  def dockerfile
    @dockerfile ||= Pathname.new("#{version}.Dockerfile")
  end

  def stash_changes
    if dry_run
      info("DRY RUN: Not stashing local changes.")
    else
      info("Stashing local changes...")
      exec_cmd("git stash -u") if task_helpers.git_workdir_dirty?
    end
  end

  def checkout_main_and_update
    if dry_run
      info("DRY RUN: Not checking out main branch and pulling updates.")
    else
      info("Checking out main branch and pulling updates...")
      exec_cmd("git checkout main")
      exec_cmd("git pull origin main")
    end
  end

  def create_branch_for_version
    if dry_run
      info("DRY RUN: Not creating branch #{version}.")
    else
      info("Creating branch #{version}...")
      exec_cmd("git checkout -b #{version}")
    end
  end

  def create_dockerfile
    single_dockerfile = Pathname.new('dockerfiles/single.Dockerfile')

    if dry_run
      info("DRY RUN: Not creating file #{dockerfile}.")
    else
      info("Creating file #{dockerfile}...")
      dockerfile.open('w') do |post|
        post.write(single_dockerfile.read.gsub('ARG VER', "ARG VER=#{version}"))
      end
    end
  end

  def commit_dockerfile
    if dry_run
      info("DRY RUN: Not adding file #{dockerfile} to branch #{version} or commiting changes.")
    else
      info("Adding file #{dockerfile} and commiting changes to branch #{version}...")
      exec_cmd("git add #{version}.Dockerfile")
      exec_cmd("git commit -m 'Release cut #{version}'")
    end
  end

  def git_push_branch
    if dry_run
      info("DRY RUN: Not pushing branch #{version}.")
    else
      info("Pushing branch #{version}. Don't create a merge request...")
      exec_cmd("git push origin #{version}")
    end
  end

  def task_helpers
    @task_helpers ||= TaskHelpers.new
  end

  def exec_cmd(cmd)
    `#{cmd}`
  end

  def info(msg)
    task_helpers.info("gitlab-docs", msg)
  end

  def error(msg)
    task_helpers.error("gitlab-docs", msg)
  end
end

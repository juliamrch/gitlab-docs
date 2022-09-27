# frozen_string_literal: true

require './lib/tasks/task_helpers'
require 'fileutils'
require "highline/import"

task_helpers = TaskHelpers.new

namespace :release do
  desc 'Creates a single release archive'
  task :single, :version do |t, args|
    version = args.version.to_s

    # Disable lefthook because it was causing some PATH errors
    # https://docs.gitlab.com/ee/development/contributing/style_guides.html#disable-lefthook-temporarily
    ENV['LEFTHOOK'] = '0'

    raise 'You need to specify a version, like 10.1' unless version.match?(%r{\A\d+\.\d+\z})

    # Check if local branch exists
    abort("\n#{TaskHelpers::COLOR_CODE_RED}ERROR: Rake aborted! The branch already exists. Delete it with `git branch -D #{version}` and rerun the task.#{TaskHelpers::COLOR_CODE_RESET}") \
      if task_helpers.local_branch_exist?(version)

    # Stash modified and untracked files so we have "clean" environment
    # without accidentally deleting data
    puts "\n#{TaskHelpers::COLOR_CODE_GREEN}INFO: Stashing changes..#{TaskHelpers::COLOR_CODE_RESET}"
    `git stash -u` if task_helpers.git_workdir_dirty?

    # Sync with upstream default branch
    `git checkout #{ENV['CI_DEFAULT_BRANCH']}`
    `git pull origin #{ENV['CI_DEFAULT_BRANCH']}`

    # Create branch
    `git checkout -b #{version}`

    # Set version variable in X.Y.Dockerfile
    dockerfile = "#{version}.Dockerfile"

    if File.exist?(dockerfile)
      abort('rake aborted!') if ask("#{dockerfile} already exists. Do you want to overwrite?", %w[y n]) == 'n'
    end

    content = File.read('dockerfiles/single.Dockerfile')
    content.gsub!('ARG VER', "ARG VER=#{version}")

    File.open(dockerfile, 'w') do |post|
      post.puts content
    end

    # Update GitLab version variable in .gitlab/ci/docker-images.gitlab-ci.yml
    ci_yaml = ".gitlab/ci/docker-images.gitlab-ci.yml"
    ci_yaml_content = File.read(ci_yaml)
    ci_yaml_content.gsub!(/GITLAB_VERSION: \S+/, "GITLAB_VERSION: '#{version}'")

    File.open(ci_yaml, 'w') do |post|
      post.puts ci_yaml_content
    end

    # Add and commit
    `git add .gitlab/ci/docker-images.gitlab-ci.yml #{version}.Dockerfile`
    `git commit -m 'Release cut #{version}'`

    puts "\n#{TaskHelpers::COLOR_CODE_GREEN}INFO: Created new Dockerfile:#{TaskHelpers::COLOR_CODE_RESET} #{dockerfile}."
    puts "#{TaskHelpers::COLOR_CODE_GREEN}INFO: Pushing the new branch. Don't create a merge request!#{TaskHelpers::COLOR_CODE_RESET}"

    `git push origin #{version}`
  end
end

# frozen_string_literal: true

require './lib/tasks/task_helpers'
require 'fileutils'
require 'pathname'

task_helpers = TaskHelpers.new

task default: [:clone_repositories, :generate_feature_flags]

task :setup_git do
  puts "\n#{COLOR_CODE_GREEN}INFO: Setting up dummy user and email in Git..#{COLOR_CODE_RESET}"

  `git config --global user.name "Sidney Jones"`
  `git config --global user.email "sidneyjones@example.com"`
end

desc 'Clone Git repositories of documentation projects, keeping only the most recent commit'
task :clone_repositories do
  task_helpers.products.each_value do |product|
    branch = task_helpers.retrieve_branch(product['slug'])

    # Limit the pipeline to pull only the repo where the MR is, not all 4, to save time/space.
    # First we check if the branch on the docs repo is other than the default branch and
    # then we skip if the remote branch variable is the default branch name. Finally,
    # check if the pipeline was triggered via the API (multi-project pipeline)
    # to exclude the case where we create a branch right off the gitlab-docs
    # project.
    next if ENV["CI_COMMIT_REF_NAME"] != ENV['CI_DEFAULT_BRANCH'] \
      && branch == ENV['CI_DEFAULT_BRANCH'] \
      && ENV["CI_PIPELINE_SOURCE"] == 'pipeline'

    puts "\n#{COLOR_CODE_GREEN}INFO: Cloning #{product['repo']}..#{COLOR_CODE_RESET}"

    `git clone --branch #{branch} --single-branch #{product['repo']} --depth 1 #{product['project_dir']}`

    # Print the latest commit from each project so that we can see which commit we're building from.
    puts "\n#{COLOR_CODE_GREEN}INFO: Latest commit: #{`git -C #{product['project_dir']} log --oneline -n 1`}#{COLOR_CODE_RESET}"
  end
end

desc 'Generate feature flags data file'
task :generate_feature_flags do
  feature_flags_dir = Pathname.new('..').join('gitlab', 'config', 'feature_flags').expand_path
  feature_flags_ee_dir = Pathname.new('..').join('gitlab', 'ee', 'config', 'feature_flags').expand_path

  abort("\n#{COLOR_CODE_RED}ERROR: The feature flags directory #{feature_flags_dir} does not exist.#{COLOR_CODE_RESET}") unless feature_flags_dir.exist?
  abort("\n#{COLOR_CODE_RED}ERROR: The feature flags EE directory #{feature_flags_ee_dir} does not exist.#{COLOR_CODE_RESET}") unless feature_flags_ee_dir.exist?

  paths = {
    'GitLab Community Edition and Enterprise Edition' => feature_flags_dir.join('**', '*.yml'),
    'GitLab Enterprise Edition only' => feature_flags_ee_dir.join('**', '*.yml')
  }

  feature_flags = {
    products: {}
  }

  paths.each do |key, path|
    feature_flags[:products][key] = []

    Dir.glob(path).each do |feature_flag_yaml|
      feature_flags[:products][key] << YAML.safe_load(File.read(feature_flag_yaml))
    end
  end

  feature_flags_yaml = File.join('content', '_data', 'feature_flags.yaml')

  puts "\n#{COLOR_CODE_GREEN}INFO: Generating #{feature_flags_yaml}..#{COLOR_CODE_RESET}"
  File.write(feature_flags_yaml, feature_flags.to_yaml)
end

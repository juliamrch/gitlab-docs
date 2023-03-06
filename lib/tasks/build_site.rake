# frozen_string_literal: true

require './lib/tasks/task_helpers'
require 'fileutils'
require 'pathname'

task_helpers = TaskHelpers.new

desc 'Clone Git repositories of documentation projects, keeping only the most recent commit'
task :clone_repositories do
  task_helpers.products.each_value do |product|
    branch, refspec = task_helpers.retrieve_branch(product['slug'])

    # Limit the pipeline to pull only the repo where the MR is, not all 4, to save time/space.
    # First we check if the branch on the docs repo is other than the default branch and
    # then we skip if the remote branch variable is the default branch name. Finally,
    # check if the pipeline was triggered via the API (multi-project pipeline)
    # to exclude the case where we create a branch right off the gitlab-docs
    # project.
    next if ENV["CI_COMMIT_REF_NAME"] != ENV['CI_DEFAULT_BRANCH'] \
      && branch == ENV['CI_DEFAULT_BRANCH'] \
      && ENV["CI_PIPELINE_SOURCE"] == 'pipeline'

    puts "\n#{TaskHelpers::COLOR_CODE_GREEN}INFO: Cloning branch '#{branch}' of #{product['repo']}..#{TaskHelpers::COLOR_CODE_RESET}"

    #
    # Handle the cases where we land on a runner that already ran a docs build,
    # to make sure we're not reusing an old version of the docs, or a review
    # app's content.
    #
    # Remove the cloned repository if it already exists and either the
    # CI (when run in the runner context) or REMOVE_BEFORE_CLONE (when run localy)
    # variables are set.
    #
    if Dir.exist?(product['project_dir'])
      if ENV['CI'] || ENV['REMOVE_BEFORE_CLONE']
        puts "#{product['project_dir']} already exists. Removing it..."
        FileUtils.rm_rf(product['project_dir'])
      else
        abort("\n#{TaskHelpers::COLOR_CODE_RED}ERROR: Failed to remove #{product['repo']}. To force remove it, use REMOVE_BEFORE_CLONE=true#{TaskHelpers::COLOR_CODE_RESET}")
      end
    end

    Dir.mkdir(product['project_dir'])

    Dir.chdir(product['project_dir']) do
      `git -c init.defaultBranch=#{branch} init`
      `git remote add origin #{product['repo']}`
      `git fetch --depth 1 origin #{refspec}`
      `git -c advice.detachedHead=false checkout FETCH_HEAD`
    end

    latest_commit = `git -C #{product['project_dir']} log --oneline -n 1`

    abort("\n#{TaskHelpers::COLOR_CODE_RED}ERROR: Failed to clone #{product['repo']}.#{TaskHelpers::COLOR_CODE_RESET}") if latest_commit.empty?

    # Print the latest commit from each project so that we can see which commit we're building from.
    puts "\n#{TaskHelpers::COLOR_CODE_GREEN}INFO: Latest commit: #{latest_commit}#{TaskHelpers::COLOR_CODE_RESET}"
  end
end

desc 'Generate feature flags data file'
task :generate_feature_flags do
  feature_flags_dir = Pathname.new('..').join('gitlab', 'config', 'feature_flags').expand_path
  feature_flags_ee_dir = Pathname.new('..').join('gitlab', 'ee', 'config', 'feature_flags').expand_path

  abort("\n#{TaskHelpers::COLOR_CODE_RED}ERROR: The feature flags directory #{feature_flags_dir} does not exist.#{TaskHelpers::COLOR_CODE_RESET}") unless feature_flags_dir.exist?
  abort("\n#{TaskHelpers::COLOR_CODE_RED}ERROR: The feature flags EE directory #{feature_flags_ee_dir} does not exist.#{TaskHelpers::COLOR_CODE_RESET}") unless feature_flags_ee_dir.exist?

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

  puts "\n#{TaskHelpers::COLOR_CODE_GREEN}INFO: Generating #{feature_flags_yaml}..#{TaskHelpers::COLOR_CODE_RESET}"
  File.write(feature_flags_yaml, feature_flags.to_yaml)
end

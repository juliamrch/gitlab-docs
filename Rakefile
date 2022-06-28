# frozen_string_literal: true

require './lib/task_helpers'
require 'fileutils'
require 'pathname'

COLOR_CODE_RESET = "\e[0m"
COLOR_CODE_RED = "\e[31m"
COLOR_CODE_GREEN = "\e[32m"

task default: [:clone_repositories, :generate_feature_flags]

task :setup_git do
  puts "\n#{COLOR_CODE_GREEN}INFO: Setting up dummy user and email in Git..#{COLOR_CODE_RESET}"

  `git config --global user.name "Sidney Jones"`
  `git config --global user.email "sidneyjones@example.com"`
end

desc 'Clone Git repositories of documentation projects, keeping only the most recent commit'
task :clone_repositories do
  products.each_value do |product|
    branch = retrieve_branch(product['slug'])

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

namespace :release do
  desc 'Creates a single release archive'
  task :single, :version do |t, args|
    require "highline/import"
    version = args.version.to_s
    source_dir = File.expand_path(__dir__)

    raise 'You need to specify a version, like 10.1' unless version.match?(%r{\A\d+\.\d+\z})

    # Check if local branch exists
    abort("\n#{COLOR_CODE_RED}ERROR: Rake aborted! The branch already exists. Delete it with `git branch -D #{version}` and rerun the task.#{COLOR_CODE_RESET}") \
      if local_branch_exist?(version)

    # Stash modified and untracked files so we have "clean" environment
    # without accidentally deleting data
    puts "\n#{COLOR_CODE_GREEN}INFO: Stashing changes..#{COLOR_CODE_RESET}"
    `git stash -u` if git_workdir_dirty?

    # Sync with upstream default branch
    `git checkout #{ENV['CI_DEFAULT_BRANCH']}`
    `git pull origin #{ENV['CI_DEFAULT_BRANCH']}`

    # Create branch
    `git checkout -b #{version}`

    # Replace the branches variables in Dockerfile.X.Y
    dockerfile = "#{source_dir}/#{version}.Dockerfile"

    if File.exist?(dockerfile)
      abort('rake aborted!') if ask("#{dockerfile} already exists. Do you want to overwrite?", %w[y n]) == 'n'
    end

    content = File.read('dockerfiles/single.Dockerfile')
    content.gsub!('X.Y', version)
    content.gsub!('X-Y', version.tr('.', '-'))
    content.gsub!('W-Z', chart_version(version).tr('.', '-'))

    File.open(dockerfile, 'w') do |post|
      post.puts content
    end

    # Replace the branches variables in .gitlab-ci.yml
    ci_yaml = "#{source_dir}/.gitlab-ci.yml"
    ci_yaml_content = File.read(ci_yaml)
    ci_yaml_content.gsub!("BRANCH_EE: 'master'", "BRANCH_EE: '#{version.tr('.', '-')}-stable-ee'")
    ci_yaml_content.gsub!("BRANCH_OMNIBUS: 'master'", "BRANCH_OMNIBUS: '#{version.tr('.', '-')}-stable'")
    ci_yaml_content.gsub!("BRANCH_RUNNER: 'main'", "BRANCH_RUNNER: '#{version.tr('.', '-')}-stable'")
    ci_yaml_content.gsub!("BRANCH_CHARTS: 'master'", "BRANCH_CHARTS: '#{chart_version(version).tr('.', '-')}-stable'")

    File.open(ci_yaml, 'w') do |post|
      post.puts ci_yaml_content
    end

    # Add and commit
    `git add .gitlab-ci.yml #{version}.Dockerfile`
    `git commit -m 'Release cut #{version}'`

    puts "\n#{COLOR_CODE_GREEN}INFO: Created new Dockerfile:#{COLOR_CODE_RESET} #{dockerfile}."
    puts "#{COLOR_CODE_GREEN}INFO: To push the new branch, run:#{COLOR_CODE_RESET} git push origin #{version}."
  end

  desc 'Creates merge requests to update the dropdowns in all online versions'
  task :dropdowns do
    # Check if you're on the default branch before starting. Fail if you are.
    abort("\n#{COLOR_CODE_RED}ERROR: You are on the default branch. Create the current release branch and run the Rake task again.#{COLOR_CODE_RESET}") if `git branch --show-current`.tr("\n", '') == ENV['CI_DEFAULT_BRANCH']

    # Load online versions
    versions = YAML.load_file('./content/_data/versions.yaml')

    # The first online version should be the current stable one
    current_version = versions['online'].first

    # The release branch name
    release_branch = "release-#{current_version.tr('.', '-')}"

    # Check if a release branch has been created, if not fail and warn the user
    abort("\n#{COLOR_CODE_RED}ERROR: A release branch for the latest stable version has not been created.#{COLOR_CODE_RESET}") if `git rev-parse --verify #{release_branch}`.empty?

    # Create a merge request to update the dropdowns in all online versions
    versions['online'].each do |version|
      # Set the commit title
      mr_title = "Update #{version} dropdown to match that of #{current_version}"
      mr_description = "Update version dropdown of #{version} release for the #{current_version} release."
      branch_name = "update-#{version.tr('.', '-')}-for-release-#{current_version.tr('.', '-')}"

      puts "\n#{COLOR_CODE_GREEN}INFO: Fetching #{version} stable branch..#{COLOR_CODE_RESET}"
      `git fetch origin #{version}`

      puts "\n#{COLOR_CODE_GREEN}INFO: Creating a new branch off of the online version..#{COLOR_CODE_RESET}"
      `git checkout -b #{branch_name} origin/#{version}`
      `git reset --hard origin/#{version}`

      puts "\n#{COLOR_CODE_GREEN}INFO: Copying the versions.yaml content from the release-#{current_version} branch..#{COLOR_CODE_RESET}"
      `git checkout release-#{current_version.tr('.', '-')} -- content/_data/versions.yaml`

      puts "\n#{COLOR_CODE_GREEN}INFO: Committing and pushing to create a merge request..#{COLOR_CODE_RESET}"
      `git commit -m "Update dropdown to #{current_version}"`
      `git push --set-upstream origin #{branch_name} -o merge_request.create -o merge_request.target=#{version} -o merge_request.remove_source_branch -o merge_request.title="#{mr_title}" -o merge_request.description="#{mr_description}" -o merge_request.label="Technical Writing" -o merge_request.label="release" -o merge_request.label="Category:Docs Site" -o merge_request.label="type::maintenance"`
    end

    # Create a merge request to update the dropdowns in all previous major online versions
    versions['previous_majors'].each do |version|
      # Set the commit title
      mr_title = "Update #{version} dropdown to match that of #{current_version}"
      mr_description = "Update version dropdown of #{version} release for the #{current_version} release."
      branch_name = "update-#{version.tr('.', '-')}-for-release-#{current_version.tr('.', '-')}"

      puts "\n#{COLOR_CODE_GREEN}INFO: Fetching #{version} stable branch..#{COLOR_CODE_RESET}"
      `git fetch origin #{version}`

      puts "\n#{COLOR_CODE_GREEN}INFO: Creating a new branch off of the online version..#{COLOR_CODE_RESET}"
      `git checkout -b #{branch_name} origin/#{version}`
      `git reset --hard origin/#{version}`

      puts "\n#{COLOR_CODE_GREEN}INFO: Copying the versions.yaml content from the release-#{current_version} branch..#{COLOR_CODE_RESET}"
      `git checkout release-#{current_version.tr('.', '-')} -- content/_data/versions.yaml`

      puts "\n#{COLOR_CODE_GREEN}INFO: Committing and pushing to create a merge request..#{COLOR_CODE_RESET}"
      `git commit -m "Update dropdown to #{current_version}"`
      `git push --set-upstream origin #{branch_name} -o merge_request.create -o merge_request.target=#{version} -o merge_request.remove_source_branch -o merge_request.title="#{mr_title}" -o merge_request.description="#{mr_description}" -o merge_request.label="Technical Writing" -o merge_request.label="release" -o merge_request.label="Category:Docs Site" -o merge_request.label="type::maintenance"`
    end

    # Switch back to the release branch after the dropdowns are pushed
    `git checkout #{release_branch}`
  end
end

desc 'Create the _redirects file'
task :redirects do
  redirects_yaml = YAML.load_file('content/_data/redirects.yaml', permitted_classes: [Date])
  redirects_file = 'public/_redirects'

  # Remove _redirects before populating it
  File.delete(redirects_file) if File.exist?(redirects_file)

  # Iterate over each entry and append to _redirects
  redirects_yaml.fetch('redirects').each do |redirect|
    File.open(redirects_file, 'a') do |f|
      f.puts "#{redirect.fetch('from')} #{redirect.fetch('to')} 301"
    end
  end
end

#
# https://docs.gitlab.com/ee/development/documentation/#move-or-rename-a-page
#
namespace :docs do
  require 'date'
  require 'pathname'
  require "yaml"
  desc 'GitLab | Docs | Clean up old redirects'
  task :clean_redirects do
    source_dir = File.expand_path(__dir__)
    redirects_yaml = "#{source_dir}/content/_data/redirects.yaml"
    today = Time.now.utc.to_date
    mr_title = "Clean up docs redirects - #{today}"
    mr_description = "Monthly cleanup of docs redirects.</br><p>See https://about.gitlab.com/handbook/engineering/ux/technical-writing/#regularly-scheduled-tasks</p></br></hr></br><p>_Created automatically: https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/doc/raketasks.md#clean-up-redirects_</p>"
    redirects_branch = "docs-clean-redirects-#{today}"
    commit_message = "Update docs redirects #{today}"

    # Disable lefthook because it was causing some PATH errors
    # https://docs.gitlab.com/ee/development/contributing/style_guides.html#disable-lefthook-temporarily
    ENV['LEFTHOOK'] = '0'

    # Check jq is available
    abort("\n#{COLOR_CODE_RED}ERROR: jq not found. Install jq and run task again.#{COLOR_CODE_RESET}") if `which jq`.empty?

    puts "\n#{COLOR_CODE_GREEN}INFO: (gitlab-docs): Stashing changes of gitlab-docs and syncing with upstream default branch..#{COLOR_CODE_RESET}"
    system("git stash --quiet -u") if git_workdir_dirty?
    system("git checkout --quiet main")
    system("git fetch --quiet origin main")
    system("git reset --quiet --hard origin/main")

    products.each_value do |product|
      #
      # Calculate new path from the redirect URL.
      #
      # If the redirect is not a full URL:
      #   1. Create a new Pathname of the file
      #   2. Use dirname to get all but the last component of the path
      #   3. Join with the redirect_to entry
      #   4. Substitute:
      #      - '.md' => '.html'
      #      - 'doc/' => '/ee/'
      #
      # If the redirect URL is a full URL pointing to the Docs site
      # (cross-linking among the 4 products), remove the FQDN prefix:
      #
      #   From : https://docs.gitlab.com/ee/install/requirements.html
      #   To   : /ee/install/requirements.html
      #
      def new_path(redirect, filename, content_dir, slug)
        if !redirect.start_with?('http')
          Pathname.new(filename).dirname.join(redirect).to_s.gsub(%r{\.md}, '.html').gsub(content_dir, "/#{slug}")
        elsif redirect.start_with?('https://docs.gitlab.com')
          redirect.gsub('https://docs.gitlab.com', '')
        else
          redirect
        end
      end

      content_dir = product['content_dir']
      next unless Dir.exist?(content_dir)

      default_branch = default_branch(product['repo'])
      origin_default_branch = "origin/#{default_branch}"
      slug = product['slug']
      counter = 0

      Dir.chdir(content_dir)
      puts "\n#{COLOR_CODE_GREEN}INFO: (#{slug}): Stashing changes of #{slug} and syncing with upstream default branch..#{COLOR_CODE_RESET}"
      system("git", "stash", "--quiet", "-u") if git_workdir_dirty?
      system("git", "checkout", "--quiet", default_branch)
      system("git", "fetch", "--quiet", "origin", default_branch)
      system("git", "reset", "--quiet", "--hard", origin_default_branch)
      Dir.chdir(source_dir)

      #
      # Find the files to be deleted.
      # Exclude 'doc/development/documentation/redirects.md' because it
      # contains an example of the YAML front matter.
      #
      files_to_be_deleted = `grep -Ir 'remove_date:' #{content_dir} | cut -d ":" -f1`.split("\n")
      puts "Files containing 'remove_date':"
      files_to_be_deleted.each { |file| puts "- #{file}" }
      puts

      #
      # Iterate over the files to be deleted and print the needed
      # YAML entries for the Docs site redirects.
      #
      files_to_be_deleted.each do |filename|
        frontmatter = YAML.safe_load(File.read(filename))

        # Skip if remove_date is not found in the frontmatter
        next unless frontmatter.has_key?('remove_date')

        remove_date = Date.parse(frontmatter['remove_date'])
        old_path = filename.gsub(%r{\.md}, '.html').gsub(content_dir, "/#{slug}")

        #
        # Check if the removal date is before today, and delete the file and
        # print the content to be pasted in
        # https://gitlab.com/gitlab-org/gitlab-docs/-/blob/master/content/_data/redirects.yaml.
        # The remove_date of redirects.yaml should be nine months in the future.
        # To not be confused with the remove_date of the Markdown page.
        #
        next unless remove_date < today

        puts "In #{filename}, remove date: #{remove_date} is less than today (#{today})."

        counter += 1

        File.delete(filename) if File.exist?(filename)

        # Don't add any entries that are domain-level redirects, they are not supported
        # https://docs.gitlab.com/ee/user/project/pages/redirects.html
        next if new_path(frontmatter['redirect_to'], filename, content_dir, slug).start_with?('http')

        File.open(redirects_yaml, 'a') do |post|
          post.puts "  - from: #{old_path}"
          post.puts "    to: #{new_path(frontmatter['redirect_to'], filename, content_dir, slug)}"
          post.puts "    remove_date: #{remove_date >> 9}"
        end

        # If the 'from' path ends with 'index.html' we need an extra redirect
        # entry in 'redirects.yaml' that is without 'index.html'
        next unless old_path.end_with?('index.html')

        File.open(redirects_yaml, 'a') do |post|
          post.puts "  - from: #{old_path.gsub!('index.html', '')}"
          post.puts "    to: #{new_path(frontmatter['redirect_to'], filename, content_dir, slug)}"
          post.puts "    remove_date: #{remove_date >> 9}"
        end
      end

      #
      # If more than one files are found:
      #
      #   1. cd into each repository
      #   2. Create a redirects branch
      #   3. Add the changed files
      #   4. Commit and push the branch to create the MR
      #

      puts "\n#{COLOR_CODE_GREEN}INFO: (#{slug}): Found #{counter} redirect(s).#{COLOR_CODE_RESET}"
      next unless counter.positive?

      Dir.chdir(content_dir)
      puts "\n#{COLOR_CODE_GREEN}INFO: (#{slug}): Creating a new branch for the redirects MR..#{COLOR_CODE_RESET}"
      system("git", "checkout", "--quiet", "-b", redirects_branch, origin_default_branch)
      puts "\n#{COLOR_CODE_GREEN}INFO: (#{slug}): Committing and pushing to create a merge request..#{COLOR_CODE_RESET}"
      system("git", "add", ".")
      system("git", "commit", "--quiet", "-m", commit_message)

      `git push --set-upstream origin #{redirects_branch} -o merge_request.create -o merge_request.remove_source_branch -o merge_request.title="#{mr_title}" -o merge_request.description="#{mr_description}" -o merge_request.label="Technical Writing" -o merge_request.label="documentation" -o merge_request.label="docs::improvement" -o merge_request.label="type::maintenance"` \
        if ENV['SKIP_MR'].nil?

      Dir.chdir(source_dir)
      puts
    end

    #
    # Finally, create the gitlab-docs MR
    #
    #   1. Create a redirects branch
    #   2. Add the changed files
    #   3. Commit and push the branch to create the MR
    #
    puts "\n#{COLOR_CODE_GREEN}INFO: (gitlab-docs): Creating a new branch for the redirects MR..#{COLOR_CODE_RESET}"
    system("git", "checkout", "--quiet", "-b", redirects_branch, "origin/main")
    puts "\n#{COLOR_CODE_GREEN}INFO: (gitlab-docs): Committing and pushing to create a merge request..#{COLOR_CODE_RESET}"
    system("git", "add", redirects_yaml)
    system("git", "commit", "--quiet", "-m", commit_message)

    `git push --set-upstream origin #{redirects_branch} -o merge_request.create -o merge_request.remove_source_branch -o merge_request.title="#{mr_title}" -o merge_request.description="#{mr_description}" -o merge_request.label="Technical Writing" -o merge_request.label="redirects" -o merge_request.label="Category:Docs Site" -o merge_request.label="type::maintenance"` \
      if ENV['SKIP_MR'].nil?
  end
end

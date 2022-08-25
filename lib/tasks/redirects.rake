# frozen_string_literal: true
require './lib/tasks/task_helpers'
require 'date'
require 'pathname'
require 'fileutils'

task_helpers = TaskHelpers.new

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
    abort("\n#{TaskHelpers::COLOR_CODE_RED}ERROR: jq not found. Install jq and run task again.#{TaskHelpers::COLOR_CODE_RESET}") if `which jq`.empty?

    puts "\n#{TaskHelpers::COLOR_CODE_GREEN}INFO: (gitlab-docs): Stashing changes of gitlab-docs and syncing with upstream default branch..#{TaskHelpers::COLOR_CODE_RESET}"
    system("git stash --quiet -u") if git_workdir_dirty?
    system("git checkout --quiet main")
    system("git fetch --quiet origin main")
    system("git reset --quiet --hard origin/main")

    task_helpers.products.each_value do |product|
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

      default_branch = task_helpers.default_branch(product['repo'])
      origin_default_branch = "origin/#{default_branch}"
      slug = product['slug']
      counter = 0

      Dir.chdir(content_dir)
      puts "\n#{TaskHelpers::COLOR_CODE_GREEN}INFO: (#{slug}): Stashing changes of #{slug} and syncing with upstream default branch..#{TaskHelpers::COLOR_CODE_RESET}"
      system("git", "stash", "--quiet", "-u") if task_helpers.git_workdir_dirty?
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

      puts "\n#{TaskHelpers::COLOR_CODE_GREEN}INFO: (#{slug}): Found #{counter} redirect(s).#{TaskHelpers::COLOR_CODE_RESET}"
      next unless counter.positive?

      Dir.chdir(content_dir)
      puts "\n#{TaskHelpers::COLOR_CODE_GREEN}INFO: (#{slug}): Creating a new branch for the redirects MR..#{TaskHelpers::COLOR_CODE_RESET}"
      system("git", "checkout", "--quiet", "-b", redirects_branch, origin_default_branch)
      puts "\n#{TaskHelpers::COLOR_CODE_GREEN}INFO: (#{slug}): Committing and pushing to create a merge request..#{TaskHelpers::COLOR_CODE_RESET}"
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
    puts "\n#{TaskHelpers::COLOR_CODE_GREEN}INFO: (gitlab-docs): Creating a new branch for the redirects MR..#{TaskHelpers::COLOR_CODE_RESET}"
    system("git", "checkout", "--quiet", "-b", redirects_branch, "origin/main")
    puts "\n#{TaskHelpers::COLOR_CODE_GREEN}INFO: (gitlab-docs): Committing and pushing to create a merge request..#{TaskHelpers::COLOR_CODE_RESET}"
    system("git", "add", redirects_yaml)
    system("git", "commit", "--quiet", "-m", commit_message)

    `git push --set-upstream origin #{redirects_branch} -o merge_request.create -o merge_request.remove_source_branch -o merge_request.title="#{mr_title}" -o merge_request.description="#{mr_description}" -o merge_request.label="Technical Writing" -o merge_request.label="redirects" -o merge_request.label="Category:Docs Site" -o merge_request.label="type::maintenance"` \
      if ENV['SKIP_MR'].nil?
  end
end

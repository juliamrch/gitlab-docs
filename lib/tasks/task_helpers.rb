# frozen_string_literal: true

require 'yaml'
require 'json'
require 'date'
require 'nanoc'
require_relative '../helpers/generic'

class TaskHelpers
  include Nanoc::Helpers::Generic

  PRODUCTS = %w[ee omnibus runner charts operator].freeze
  VERSION_FORMAT = %r{^(?<major>\d{1,2})\.(?<minor>\d{1,2})$}
  COLOR_CODE_RESET = "\e[0m"
  COLOR_CODE_RED = "\e[31m"
  COLOR_CODE_GREEN = "\e[32m"

  def self.info(slug, message)
    puts "#{TaskHelpers::COLOR_CODE_GREEN}INFO: (#{slug}): #{message} #{TaskHelpers::COLOR_CODE_RESET}"
  end

  def config
    # Parse the config file and create a hash.
    @config ||= YAML.load_file('./nanoc.yaml')
  end

  def project_root
    @project_root ||= File.expand_path('../../', __dir__)
  end

  def products
    # Pull products data from the config.
    @products ||= PRODUCTS.each_with_object({}) do |key, result|
      result[key] = config['products'][key]
    end
  end

  def retrieve_branch(slug)
    #
    # If we're NOT on a gitlab-docs stable branch, fetch the BRANCH_* environment
    # variable, and if not assigned, set to the default branch.
    #
    if stable_branch_name.nil?
      merge_request_iid = ENV.fetch("MERGE_REQUEST_IID_#{slug.upcase}", nil)
      branch_name = ENV.fetch("BRANCH_#{slug.upcase}", default_branch(products[slug].fetch('repo')))

      return branch_name, "heads/#{branch_name}" if merge_request_iid.nil?

      return branch_name, "merge-requests/#{merge_request_iid}/head"
    end

    #
    # Check the project slug to determine the branch name
    #
    stable_branch = stable_branch_for(slug)

    [stable_branch, "heads/#{stable_branch}"]
  end

  def stable_branch_for(slug)
    case slug
    when 'ee'
      "#{stable_branch_name}-ee"
    when 'omnibus', 'runner'
      stable_branch_name
    # Charts don't use the same version scheme as GitLab, we need to
    # deduct their version from the GitLab equivalent one.
    when 'charts'
      charts_stable_branch
    # If the upstream product doesn't follow a stable branch scheme, set the
    # branch to the default
    else
      default_branch(products[slug].fetch('repo'))
    end
  end

  def git_workdir_dirty?
    !`git status --porcelain`.empty?
  end

  def local_branch_exist?(branch)
    !`git branch --list #{branch}`.empty?
  end

  #
  # If we're on a gitlab-docs stable branch (or targeting one) according to the
  # regex, catch the version and return the branch name.
  # For example, 15-8-stable.
  #
  # 1. Skip if CI_COMMIT_REF_NAME is not defined (run outside the CI environment).
  # 2. If CI_COMMIT_REF_NAME matches the version format it means we're on a
  #    stable branch. Return the version format of that branch.
  # 3. If CI_MERGE_REQUEST_TARGET_BRANCH_NAME is defined and its value matches
  #    the version format, return that value.
  #
  def stable_branch_name
    @stable_branch_name ||= begin
      ref_name = ENV["CI_COMMIT_REF_NAME"]&.match(VERSION_FORMAT)
      if ref_name
        "#{ref_name[:major]}-#{ref_name[:minor]}-stable"
      else
        mr_name = ENV["CI_MERGE_REQUEST_TARGET_BRANCH_NAME"]&.match(VERSION_FORMAT)
        "#{mr_name[:major]}-#{mr_name[:minor]}-stable" if mr_name
      end
    end
  end

  #
  # The charts versions do not follow the same GitLab major number, BUT
  # they do follow a pattern https://docs.gitlab.com/charts/installation/version_mappings.html:
  #
  # 1. The minor version is the same for both
  # 2. The major version augments for both at the same time
  #
  # This means we can deduct the charts version from the GitLab version, since
  # the major charts version is always 9 versions behind its GitLab counterpart.
  #
  def charts_stable_branch
    major, minor = stable_branch_name.split('-')

    # Assume major charts version is nine less than major GitLab version.
    # If this breaks and the version isn't found, it might be because they
    # are no longer exactly 9 releases behind. Ask the distribution team
    # about it.
    major = major.to_i - 9

    "#{major}-#{minor}-stable"
  end

  def default_branch(repo)
    # Get the URL-encoded path of the project
    # https://docs.gitlab.com/ee/api/README.html#namespaced-path-encoding
    url_encoded_path = repo.sub('https://gitlab.com/', '').sub('.git', '').gsub('/', '%2F')

    `curl --silent https://gitlab.com/api/v4/projects/#{url_encoded_path} | jq --raw-output .default_branch`.tr("\n", '')
  end

  def current_milestone(release_date = Date.today.strftime("%Y-%m"))
    @current_milestone ||= begin
      # Search in the relase dates hash for this month's release date
      # and fetch the milestone version number.
      releases = JSON.parse(get_release_dates)
      releases.find { |item| item["date"].start_with?(release_date) }&.fetch("version", nil)
    end
  end
end

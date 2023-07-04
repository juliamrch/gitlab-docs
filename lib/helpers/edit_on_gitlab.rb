# frozen_string_literal: true

module Nanoc::Helpers
  module EditOnGitLab
    PRODUCT_REPOS = {
      "omnibus" => {
        project: "gitlab-org/omnibus-gitlab",
        default_branch_name: "master",
        doc_directory: "doc"
      },
      "runner" => {
        project: "gitlab-org/gitlab-runner",
        default_branch_name: "main",
        doc_directory: "docs"
      },
      "charts" => {
        project: "gitlab-org/charts/gitlab",
        default_branch_name: "master",
        doc_directory: "doc"
      },
      "operator" => {
        project: "gitlab-org/cloud-native/gitlab-operator",
        default_branch_name: "master",
        doc_directory: "doc"
      },
      "ee" => {
        project: "gitlab-org/gitlab",
        default_branch_name: "master",
        doc_directory: "doc"
      }
    }.freeze

    def edit_on_gitlab(item, editor: :simple)
      resource = resource_from_item(item)

      case editor
      when :simple
        blob_url(resource)
      when :webide
        ide_url(resource)
      else
        raise "Unknown editor: #{editor}"
      end
    end

    private

    def resource_from_item(item)
      # The item identifier is the file path of the current docs page.
      # Ex: "/ee/user/ssh.md"
      #
      # We can use the first path segement to determine which project the docs
      # reside in. If it's not a known project, then we'll assume that it's a
      # content file inside gitlab-docs.
      identifier_path = item.identifier.to_s.delete_prefix("/")
      product, _, repo_doc_path = identifier_path.partition("/")
      repo = PRODUCT_REPOS[product]
      if repo
        file_path = "#{repo[:doc_directory]}/#{repo_doc_path}"
        return repo.merge({ file_path: file_path })
      end

      {
        project: "gitlab-org/gitlab-docs",
        default_branch_name: "main",
        file_path: item[:content_filename]
      }
    end

    def blob_url(resource)
      "https://gitlab.com/#{resource[:project]}/-/blob/#{resource[:default_branch_name]}/#{resource[:file_path]}"
    end

    def ide_url(resource)
      "https://gitlab.com/-/ide/project/#{resource[:project]}/edit/#{resource[:default_branch_name]}/-/#{resource[:file_path]}"
    end
  end
end

# frozen_string_literal: true

module Nanoc::Helpers
  module EditOnGitLab
    def edit_on_gitlab(item, editor: :simple)
      # Make an array out of the content's source path.
      content_filename_array = item.identifier.to_s.split('/')
      # remove first empty item
      content_filename_array.shift
      # Get the product name.
      product = content_filename_array.shift
      # This should be the path from the doc/ directory for a given file.
      docs_content_filename = content_filename_array.join("/")

      case product
      when "omnibus"
        # omnibus-gitlab repo
        gitlab_url = "https://gitlab.com/gitlab-org/#{product}-gitlab/blob/master/doc/#{docs_content_filename}"
        gitlab_ide_url = "https://gitlab.com/-/ide/project/gitlab-org/#{product}-gitlab/edit/master/-/doc/#{docs_content_filename}"
      when "runner"
        # gitlab-runner repo
        gitlab_url = "https://gitlab.com/gitlab-org/gitlab-#{product}/blob/main/docs/#{docs_content_filename}"
        gitlab_ide_url = "https://gitlab.com/-/ide/project/gitlab-org/gitlab-#{product}/edit/main/-/docs/#{docs_content_filename}"
      when "charts"
        # GitLab Helm chart repo
        gitlab_url = "https://gitlab.com/gitlab-org/#{product}/gitlab/blob/master/doc/#{docs_content_filename}"
        gitlab_ide_url = "https://gitlab.com/-/ide/project/gitlab-org/#{product}/gitlab/edit/master/-/doc/#{docs_content_filename}"
      when "operator"
        # GitLab Operator repo
        gitlab_url = "https://gitlab.com/gitlab-org/cloud-native/gitlab-#{product}/blob/master/doc/#{docs_content_filename}"
        gitlab_ide_url = "https://gitlab.com/-/ide/project/gitlab-org/cloud-native/gitlab-#{product}/edit/master/-/doc/#{docs_content_filename}"
      when "ee"
        # gitlab-foss and gitlab repos
        gitlab_url = "https://gitlab.com/gitlab-org/gitlab/blob/master/doc/#{docs_content_filename}"
        gitlab_ide_url = "https://gitlab.com/-/ide/project/gitlab-org/gitlab/edit/master/-/doc/#{docs_content_filename}"
      else
        # gitlab-docs pages
        gitlab_url = "https://gitlab.com/gitlab-org/gitlab-docs/blob/main/#{item[:content_filename]}"
        gitlab_ide_url = "https://gitlab.com/-/ide/project/gitlab-org/gitlab-docs/edit/main/-/#{item[:content_filename]}"
      end

      case editor
      when :simple
        gitlab_url
      when :webide
        gitlab_ide_url
      else
        raise "Unknown editor: #{editor}"
      end
    end
  end
end

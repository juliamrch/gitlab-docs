# frozen_string_literal: true

module Nanoc::Helpers
  module Admonition
    BOOTSTRAP_MAPPING = {
      'note' => 'note',
      'warning' => 'warning',
      'flag' => 'flag',
      'info' => 'info',
      'disclaimer' => 'disclaimer'
    }.freeze

    GITLAB_SVGS_MAPPING = {
      'note' => 'information-o',
      'warning' => 'warning',
      'flag' => 'flag',
      'info' => 'tanuki',
      'disclaimer' => 'review-warning'
    }.freeze

    def admonition(kind, content)
      kind = kind.downcase
      %(<div class="mt-3 admonition-wrapper #{kind}">) +
        %(<div class="admonition admonition-non-dismissable alert alert-#{BOOTSTRAP_MAPPING[kind]}">) +
        %(<div>#{icon(GITLAB_SVGS_MAPPING[kind], 16, 'alert-icon')}<div role="alert"><div class="alert-body">#{content}</div></div></div></div></div>)
    end

    def legal_disclaimer
      admonition('DISCLAIMER', "
This page contains information related to upcoming products, features, and functionality.
It is important to note that the information presented is for informational purposes only.
Please do not rely on this information for purchasing or planning purposes.
As with all projects, the items mentioned on this page are subject to change or delay.
The development, release, and timing of any products, features, or functionality remain at the
sole discretion of GitLab Inc.
      ")
    end
  end
end

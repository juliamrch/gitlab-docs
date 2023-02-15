# frozen_string_literal: true

module Nanoc::Helpers
  module GitLabKramdown
    require 'kramdown'
    def markdown(item, _params = {})
      Nanoc::Filters::GitLabKramdown.new.run(
        item,
        {
          input: 'GitlabKramdown',
          syntax_highlighter: 'rouge',
          syntax_highlighter_opts: {
            # In kramdown 2.0, the plaintext parser was removed and replaced by the
            # :guess_lang option:
            #
            # - https://github.com/gettalong/kramdown/blob/master/doc/news/release_2_0_0.page
            # - https://github.com/gettalong/kramdown/pull/573
            guess_lang: true
          },
          default_lang: 'Plain Text',
          hard_wrap: false,
          auto_ids: true,
          toc_levels: 2..5,
          with_toc: true
        })
    end
  end
end

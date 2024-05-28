# frozen_string_literal: true

require 'gitlab-dangerfiles'

MESSAGE = <<~MSG
This merge request should be reviewed by a member of the Technical Writing team. If this merge request:

- Modifies the global navigation (`content/_data/navigation.yaml`), select the [technical writer assigned](https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments) to the relevant group.
- Modifies code in other files, select [`@sarahgerman`](https://gitlab.com/sarahgerman).
- Modifies content in other files, select a technical writer according to [reviewer roulette](https://gitlab-org.gitlab.io/gitlab-roulette/?sortKey=stats.avg7&order=-1&visible=maintainer%7Cdocs).
MSG

Gitlab::Dangerfiles.for_project(self) do |gitlab_dangerfiles|
  gitlab_dangerfiles.import_plugins
  gitlab_dangerfiles.import_dangerfiles(except: %w[changelog simple_roulette])
end

message(MESSAGE)

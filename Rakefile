# frozen_string_literal: true

require 'gitlab-dangerfiles'

# Automatically load Rake tasks stored in lib/tasks/ in files ending in .rake
Rake.add_rakelib 'lib/tasks'

# Load danger_local Rake task
Gitlab::Dangerfiles.load_tasks

task default: [:clone_repositories, :generate_feature_flags]

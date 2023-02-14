# frozen_string_literal: true

# All tasks in files placed in lib/tasks/ ending in .rake will be loaded
# automatically
Rake.add_rakelib 'lib/tasks'

task default: [:clone_repositories, :generate_feature_flags]

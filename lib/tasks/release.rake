# frozen_string_literal: true

require_relative '../release'

namespace :release do
  desc 'Creates a single release archive'
  task :single, :version do
    include TaskHelpers::Output

    begin
      Release.new.single
    rescue StandardError => e
      abort(error_format('gitlab-docs', e.message))
    end
  end

  desc 'Updates the versions dropdown JSON file'
  task :update_versions_dropdown do
    Release.new.update_versions_dropdown
  end
end

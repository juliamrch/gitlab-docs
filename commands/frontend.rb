# frozen_string_literal: true

usage       'frontend [options]'
aliases     :ds, :stuff
summary     'uses nanoc cli to execute frontend related tasks'
description 'This command is used by the Nanoc CLI to bundle JavaScript.'

flag   :h, :help, 'show help for this command' do |value, cmd|
  puts cmd.help
  exit 0
end
run do |opts, args, cmd|
  puts 'Compiling JavaScript...'

  unless system('yarn install --frozen-lockfile')
    abort <<~ERROR
      Error: failed to run yarn. JavaScript compilation failed. For more information, see:
      https://gitlab.com/gitlab-org/gitlab-docs/blob/main/README.md

    ERROR
  end

  unless system('yarn bundle')
    abort <<~ERROR
      Error: failed to run yarn. JavaScript compilation failed. For more information, see:
      https://gitlab.com/gitlab-org/gitlab-docs/blob/main/README.md

    ERROR
  end

  puts 'Copying GitLab UI CSS sourcemaps...'
  root = File.expand_path('../', __dir__)
  gl_ui_src = 'node_modules/@gitlab/ui/dist'
  gl_ui_dest = 'public/frontend/shared'

  Dir.children(gl_ui_src).each do |filename|
    puts "Copied #{gl_ui_src}/#{filename}" if filename.include?("map") && File.write("#{gl_ui_dest}/#{filename}", File.read("#{root}/#{gl_ui_src}/#{filename}"))
  end
end

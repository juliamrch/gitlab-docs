# frozen_string_literal: true

COLOR_CODE_RESET = "\e[0m"
COLOR_CODE_GREEN = "\e[32m"

usage       'frontend [options]'
aliases     :ds, :stuff
summary     'uses nanoc cli to execute frontend related tasks'
description 'This command is used by the Nanoc CLI to bundle JavaScript.'

flag   :h, :help, 'show help for this command' do |_value, cmd|
  puts cmd.help
  exit 0
end
run do |_opts, _args, _cmd|
  puts "\n#{COLOR_CODE_GREEN}INFO: Compiling JavaScript...#{COLOR_CODE_RESET}"

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

  puts "\n#{COLOR_CODE_GREEN}INFO: Copying GitLab UI CSS sourcemaps...#{COLOR_CODE_RESET}"
  root = File.expand_path('../', __dir__)
  gl_ui_src = 'node_modules/@gitlab/ui/dist'
  gl_ui_dest = 'public/frontend/shared'

  Dir.children(gl_ui_src).each do |filename|
    puts "- Copied #{gl_ui_src}/#{filename}" if filename.include?("map") && File.write("#{gl_ui_dest}/#{filename}", File.read("#{root}/#{gl_ui_src}/#{filename}"))
  end

  if ENV['SEARCH_BACKEND'] == "lunr"
    lunr_src = "node_modules/lunr/lunr.min.js"
    puts "\n#{COLOR_CODE_GREEN}INFO: Copying Lunr.js...#{COLOR_CODE_RESET}"
    puts "- Copied #{lunr_src}" if File.write('public/assets/javascripts/lunr.min.js', File.read("#{root}/#{lunr_src}"))
  end
end

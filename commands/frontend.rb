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
end

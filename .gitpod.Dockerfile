FROM gitpod/workspace-full:2023-01-16-03-31-28
USER gitpod

# Install Ruby version 3.0.5 and set it as default.
# Required when the base Gitpod Docker image doesn't provide the version of Ruby we want.
# For more information, see: https://www.gitpod.io/docs/languages/ruby.

RUN _ruby_version=ruby-3.0.5 \
    && printf "rvm_gems_path=/home/gitpod/.rvm\n" > ~/.rvmrc \
    && bash -lc "rvm reinstall ${_ruby_version} && \
                 rvm use ${_ruby_version} --default" \
    && printf "rvm_gems_path=/workspace/.rvm" > ~/.rvmrc \
    && printf "{ rvm use \$(rvm current); } >/dev/null 2>&1\n" >> "$HOME/.bashrc.d/70-ruby"

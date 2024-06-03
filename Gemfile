# frozen_string_literal: true

source 'https://rubygems.org'

gem 'nanoc', '~> 4.12.21'
gem 'rake', '~> 13.2.1'

group :nanoc do
  gem 'nanoc-live'

  # custom kramdown dialect
  gem 'gitlab_kramdown', '~> 0.28.0'

  # Needed to generate Sitemap
  gem 'builder', '~> 3.2.4'

  # Needed to compile SCSS
  gem 'sass', '3.7.4'
end

group :test, :development do
  gem 'highline', '~> 3.0.1'
  gem 'rspec', '~> 3.13.0'
  gem 'rspec-parameterized', '~> 1.0.2'
  gem 'simplecov', '~> 0.22.0', require: false
  gem 'simplecov-cobertura', '~> 2.1.0', require: false
  gem 'pry-byebug', '~> 3.10.1', require: false
  gem 'gitlab-styles', '~> 11.0.0', require: false
  gem 'webrick', '~> 1.8', '>= 1.8.1'
  gem 'json_schemer', '~> 2.3', require: false
end

group :development, :danger do
  gem 'gitlab-dangerfiles', '~> 4.7.0', require: false
end

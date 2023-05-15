# frozen_string_literal: true

source 'https://rubygems.org'

gem 'nanoc', '~> 4.12.15'
gem 'sassc', '~> 2.4.0'
gem 'rake', '~> 13.0.6'

group :nanoc do
  gem 'nanoc-live'

  # custom kramdown dialect
  gem 'gitlab_kramdown', '~> 0.26.0'

  # Needed to generate Sitemap
  gem 'builder', '~> 3.2.4'

  # Needed to compile SCSS
  gem 'sass', '3.7.4'
end

group :test, :development do
  gem 'highline', '~> 2.1.0'
  gem 'rspec', '~> 3.12.0'
  gem 'rspec-parameterized', '~> 1.0.0'
  gem 'simplecov', '~> 0.22.0', require: false
  gem 'simplecov-cobertura', '~> 2.1.0', require: false
  gem 'pry-byebug', '~> 3.10.1', require: false
  gem 'gitlab-styles', '~> 10.0.0', require: false
  gem "webrick", "~> 1.8", ">= 1.8.1"
  gem 'json_schemer', '~> 0.2', '>= 0.2.24', require: false
end

group :development, :danger do
  gem 'gitlab-dangerfiles', '~> 3.10.0', require: false
end

# frozen_string_literal: true

source 'https://rubygems.org'

gem 'nanoc', '~> 4.12.13'
gem 'sassc', '~> 2.4.0'
gem 'rake', '~> 13.0.6'

group :nanoc do
  gem 'nanoc-live'

  # custom kramdown dialect
  gem 'gitlab_kramdown', '~> 0.23.0'

  # Needed to generate Sitemap
  gem 'builder', '~> 3.2.4'

  # Needed to compile SCSS
  gem 'sass', '3.7.4'
end

group :test, :development do
  gem 'highline', '~> 2.0.3'
  gem 'rspec', '~> 3.12.0'
  gem 'rspec-parameterized', '~> 0.5.2'
  gem 'simplecov', '~> 0.21.2', require: false
  gem 'simplecov-cobertura', '~> 2.1.0', require: false
  gem 'pry-byebug', '~> 3.10.1', require: false
  gem 'gitlab-styles', '~> 9.1.0', require: false
end

group :development, :danger do
  gem 'gitlab-dangerfiles', '~> 3.6.3', require: false
end

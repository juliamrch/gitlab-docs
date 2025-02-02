# frozen_string_literal: true

require 'simplecov'
require 'simplecov-cobertura'

unless ENV['SIMPLECOV'] == '0'
  SimpleCov.start
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

$LOAD_PATH << 'lib/'

require 'rspec-parameterized'
require 'gitlab/docs'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

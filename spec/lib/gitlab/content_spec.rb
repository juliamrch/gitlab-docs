# frozen_string_literal: true

require 'spec_helper'

# See: https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/4726#note_459473659
describe 'Content directory size' do
  subject { Dir.glob('content/**/*').sum { |f| File.size(f) } }

  let(:megabyte) { 1024**2 }

  # This limit can be increased after checking that Omnibus package build does not fail
  let(:maximum_size) { 2 * megabyte }

  # `content` directory is included to the Omnibus package
  # We want to make sure that the size of the directory is small enough
  # to prevent accidental Omnibus pipeline failures.
  it { is_expected.to be < maximum_size }
end

# frozen_string_literal: true

require 'spec_helper'
require 'nanoc'
require 'helpers/versions'

RSpec.describe Nanoc::Helpers::VersionsDropdown do
    let(:mock_class) { Class.new { extend Nanoc::Helpers::VersionsDropdown } }
    subject { mock_class.latest? }

    describe '#latest?' do

        before(:each) do
            versions_mock = {:next=>"15.8",:current=>"15.7",:last_minor=>["15.6", "15.5"],:last_major=>["14.10", "13.12"]}
            allow(mock_class).to receive(:get_current_stable_version).and_return(versions_mock[:current])
            stub_const('ENV', ENV.to_hash.merge('CI_DEFAULT_BRANCH' => 'main'))
        end

        it 'returns correct value for pre-release version' do
            stub_const('ENV', ENV.to_hash.merge('CI_COMMIT_REF_NAME' => 'main'))
            expect(subject).to eq(true)
        end

        it 'returns correct value for current stable version' do
            stub_const('ENV', ENV.to_hash.merge('CI_COMMIT_REF_NAME' => '15.7'))
            expect(subject).to eq(true)
        end

        it 'returns correct value for last minor version' do
            stub_const('ENV', ENV.to_hash.merge('CI_COMMIT_REF_NAME' => '15.6'))
            expect(subject).to eq(false)
        end

        it 'returns correct value for last major' do
            stub_const('ENV', ENV.to_hash.merge('CI_COMMIT_REF_NAME' => '14.10'))
            expect(subject).to eq(false)
        end

      end

end

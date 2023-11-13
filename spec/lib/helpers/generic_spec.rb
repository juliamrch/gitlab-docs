# frozen_string_literal: true

require 'spec_helper'
require 'nanoc'
require 'helpers/generic'

RSpec.describe Nanoc::Helpers::Generic do
  let(:mock_class) { Class.new { extend Nanoc::Helpers::Generic } }
  let(:path) { "ee/user/project/code_intelligence.html" }
  let(:title) { "Code Intelligence" }
  let(:mock_item) do
    item = Struct.new(:title, :path)
    item.new(title, path)
  end

  before do
    mock_items = { '/_data/navigation.yaml' => YAML.load_file('spec/lib/fixtures/navigation-mock.yaml', symbolize_names: true) }
    mock_sections = mock_items['/_data/navigation.yaml'][:sections]
    allow(mock_class).to receive(:get_nav_sections).and_return(mock_sections)
  end

  describe '#docs_section' do
    using RSpec::Parameterized::TableSyntax

    subject(:docs_section) { mock_class.docs_section(mock_item.title, mock_item.path) }

    where(:path, :title, :expected_section_title) do
      "/ee/tutorials/" | "Learn GitLab with tutorials" | "Tutorials"
      "/ee/ci/quick_start/" | "Tutorial: Create your first pipeline" | "Tutorials"
      "/ee/topics/set_up_organization.html" | "Set up your organization" | "Use GitLab"
      "/ee/user/project/autocomplete_characters.html" | "Autocomplete characters" | "Use GitLab"
      "/ee/policy/alpha-beta-support.html" | "Support for Experiment, Beta, and Generally Available features" | "Subscribe"
      "/updog.html" | "Test page" | nil
    end

    with_them do
      it "returns the section title for the given path" do
        expect(docs_section).to eq(expected_section_title)
      end
    end
  end

  describe '#build_breadcrumb_list' do
    # Test all six levels of the menu
    let(:test_data) do
      [
        {
          path: '/ee/user/',
          expected_items: [
            {
              '@type': "ListItem",
              position: 1,
              name: "Use GitLab"
            }
          ]
        },
        {
          path: '/ee/topics/set_up_organization.html',
          expected_items: [
            {
              '@type': "ListItem",
              position: 1,
              name: "Use GitLab",
              item: "https://docs.gitlab.com/ee/user/"
            },
            {
              '@type': "ListItem",
              position: 2,
              name: "Set up your organization"
            }
          ]
        },
        {
          path: '/ee/user/namespace/',
          expected_items: [
            {
              '@type': "ListItem",
              position: 1,
              name: "Use GitLab",
              item: "https://docs.gitlab.com/ee/user/"
            },
            {
              '@type': "ListItem",
              position: 2,
              name: "Set up your organization",
              item: "https://docs.gitlab.com/ee/topics/set_up_organization.html"
            },
            {
              '@type': "ListItem",
              position: 3,
              name: "Namespaces"
            }
          ]
        },
        {
          path: '/ee/user/group/manage.html',
          expected_items: [
            {
              '@type': "ListItem",
              position: 1,
              name: "Use GitLab",
              item: "https://docs.gitlab.com/ee/user/"
            },
            {
              '@type': "ListItem",
              position: 2,
              name: "Set up your organization",
              item: "https://docs.gitlab.com/ee/topics/set_up_organization.html"
            },
            {
              '@type': "ListItem",
              position: 3,
              name: "Groups",
              item: "https://docs.gitlab.com/ee/user/group/"
            },
            {
              '@type': "ListItem",
              position: 4,
              name: "Manage groups"
            }
          ]
        },
        {
          path: '/ee/user/group/saml_sso/scim_setup.html',
          expected_items: [
            {
              '@type': "ListItem",
              position: 1,
              name: "Use GitLab",
              item: "https://docs.gitlab.com/ee/user/"
            },
            {
              '@type': "ListItem",
              position: 2,
              name: "Set up your organization",
              item: "https://docs.gitlab.com/ee/topics/set_up_organization.html"
            },
            {
              '@type': "ListItem",
              position: 3,
              name: "Groups",
              item: "https://docs.gitlab.com/ee/user/group/"
            },
            {
              '@type': "ListItem",
              position: 4,
              name: "SAML SSO for GitLab.com groups",
              item: "https://docs.gitlab.com/ee/user/group/saml_sso/"
            },
            {
              '@type': "ListItem",
              position: 5,
              name: "Configure SCIM"
            }
          ]
        },
        {
          path: '/ee/topics/autodevops/cicd_variables.html',
          expected_items: [
            {
              '@type': "ListItem",
              position: 1,
              name: "Use GitLab",
              item: "https://docs.gitlab.com/ee/user/"
            },
            {
              '@type': "ListItem",
              position: 2,
              name: "Build your application",
              item: "https://docs.gitlab.com/ee/topics/build_your_application.html"
            },
            {
              '@type': "ListItem",
              position: 3,
              name: "CI/CD",
              item: "https://docs.gitlab.com/ee/ci/"
            },
            {
              '@type': "ListItem",
              position: 4,
              name: "Auto DevOps",
              item: "https://docs.gitlab.com/ee/topics/autodevops/"
            },
            {
              '@type': "ListItem",
              position: 5,
              name: "Customize",
              item: "https://docs.gitlab.com/ee/topics/autodevops/customize.html"
            },
            {
              '@type': "ListItem",
              position: 6,
              name: "CI/CD variables"
            }
          ]
        }
      ]
    end

    it 'returns an array of menu items in schema.org breadcrumblist format' do
      test_data.each do |data|
        expected_items = data[:expected_items]
        expected_json = {
          '@context': "https://schema.org",
          '@type': "BreadcrumbList",
          itemListElement: expected_items
        }
        param_value = data[:path]
        expect(mock_class.build_breadcrumb_list(param_value)).to eq(expected_json)
      end
    end
  end

  describe '#docs_breadcrumb_list' do
    using RSpec::Parameterized::TableSyntax

    subject(:docs_breadcrumb_list) { mock_class.docs_breadcrumb_list(mock_item.path) }

    where(:path, :expected_breadcrumb_list) do
      "/ee/tutorials/" | "Tutorials"
      "/ee/topics/set_up_organization.html" | "Use GitLab &rsaquo; Set up your organization"
      "/ee/user/project/autocomplete_characters.html" | "Use GitLab &rsaquo; Plan and track work &rsaquo; Quick actions &rsaquo; Autocomplete characters"
      "/ee/user/project/settings/import_export_troubleshooting.html" | "Use GitLab &rsaquo; Organize work with projects &rsaquo; Migrate projects using file exports &rsaquo; Troubleshooting"
      "/updog.html" | ""
    end

    with_them do
      it "returns the breadcrumb trail for the given path" do
        expect(docs_breadcrumb_list).to eq(expected_breadcrumb_list)
      end
    end
  end

  describe '#get_release_dates' do
    subject(:release_dates) { mock_class.get_release_dates }

    valid_yaml_content = "- version: '18.0'\n  date: '2025-05-15'"
    invalid_yaml_content = "version: '18.0'date: 2025-05-15'"

    it 'returns a JSON array when the YAML is valid' do
      allow(Net::HTTP).to receive(:get_response).and_return(Net::HTTPSuccess.new('1.1', '200', 'OK'))
      allow_any_instance_of(Net::HTTPSuccess).to receive(:body).and_return(valid_yaml_content)
      expect(release_dates).to be_a(String)
    end

    it 'returns an empty JSON array when the YAML is invalid' do
      allow(Net::HTTP).to receive(:get_response).and_return(Net::HTTPSuccess.new('1.1', '200', 'OK'))
      allow_any_instance_of(Net::HTTPSuccess).to receive(:body).and_return(invalid_yaml_content)
      allow(mock_class).to receive(:warn).with('Error getting release dates - (<unknown>): did not find expected key while parsing a block mapping at line 1 column 1')
      expect(release_dates).to eq("[]")
    end

    it 'returns an empty JSON array on HTTP error' do
      allow(Net::HTTP).to receive(:get_response).and_return(Net::HTTPServerError.new('1.1', '500', 'Internal Server Error'))
      expect(release_dates).to eq("[]")
    end

    it 'returns an empty JSON array on other errors' do
      allow(Net::HTTP).to receive(:get_response).and_raise(StandardError.new('Some error message'))
      allow(mock_class).to receive(:warn).with('Error getting release dates - Some error message')
      expect(release_dates).to eq("[]")
    end
  end

  describe '#gitlab_analytics_enabled?' do
    context 'when GITLAB_ANALYTICS_HOST and GITLAB_ANALYTICS_ID are set' do
      before do
        ENV['GITLAB_ANALYTICS_HOST'] = 'https://collector.com'
        ENV['GITLAB_ANALYTICS_ID'] = '123'
      end

      it 'returns true' do
        expect(mock_class.gitlab_analytics_enabled?).to be_truthy
      end
    end

    context 'when only GITLAB_ANALYTICS_HOST is set' do
      before do
        ENV['GITLAB_ANALYTICS_HOST'] = 'https://collector.com'
        ENV['GITLAB_ANALYTICS_ID'] = nil
      end

      it 'returns false' do
        expect(mock_class.gitlab_analytics_enabled?).to be_falsey
      end
    end

    context 'when only GITLAB_ANALYTICS_ID is set' do
      before do
        ENV['GITLAB_ANALYTICS_HOST'] = nil
        ENV['GITLAB_ANALYTICS_ID'] = '123'
      end

      it 'returns false' do
        expect(mock_class.gitlab_analytics_enabled?).to be_falsey
      end
    end

    context 'when neither GITLAB_ANALYTICS_HOST nor GITLAB_ANALYTICS_ID are set' do
      before do
        ENV['GITLAB_ANALYTICS_HOST'] = nil
        ENV['GITLAB_ANALYTICS_ID'] = nil
      end

      it 'returns false' do
        expect(mock_class.gitlab_analytics_enabled?).to be_falsey
      end
    end
  end

  describe '#gitlab_analytics_json' do
    context 'when gitlab analytics is enabled' do
      before do
        ENV['GITLAB_ANALYTICS_ID'] = '123'
        ENV['GITLAB_ANALYTICS_HOST'] = 'https://collector.com'
        allow(mock_class).to receive(:gitlab_analytics_enabled?).and_return(true)
      end

      it 'returns the configuration object' do
        expected_json = {
          'appId' => '123',
          'host' => 'https://collector.com',
          'hasCookieConsent' => true
        }.to_json

        expect(mock_class.gitlab_analytics_json).to eq(expected_json)
      end
    end

    context 'when gitlab analytics is not enabled' do
      before do
        allow(mock_class).to receive(:gitlab_analytics_enabled?).and_return(false)
      end

      it 'returns nil' do
        expect(mock_class.gitlab_analytics_json).to be_nil
      end
    end
  end
end

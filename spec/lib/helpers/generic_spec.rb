# frozen_string_literal: true

require 'spec_helper'
require 'nanoc'
require 'helpers/generic'

RSpec.describe Nanoc::Helpers::Generic do
  let(:mock_class) { Class.new { extend Nanoc::Helpers::Generic } }
  let(:path) { "ee/user/project/code_intelligence.html" }
  let(:mock_item) do
    item = Struct.new(:path)
    item.new(path)
  end

  before do
    mock_items = { '/_data/navigation.yaml' => YAML.load_file('spec/lib/fixtures/navigation-mock.yaml', symbolize_names: true) }
    mock_sections = mock_items['/_data/navigation.yaml'][:sections]
    allow(mock_class).to receive(:get_nav_sections).and_return(mock_sections)
  end

  describe '#docs_section' do
    using RSpec::Parameterized::TableSyntax

    subject { mock_class.docs_section(mock_item.path.to_s) }

    where(:path, :expected_section_title) do
      "/ee/tutorials/" | "Learn GitLab with tutorials"
      "/ee/topics/set_up_organization.html" | "Use GitLab"
      "/ee/user/project/autocomplete_characters.html" | "Use GitLab"
      "/ee/policy/alpha-beta-support.html" | "Manage GitLab subscription"
      "/updog.html" | nil
    end

    with_them do
      it "returns the section title for the given path" do
        expect(subject).to eq(expected_section_title)
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

    subject { mock_class.docs_breadcrumb_list(mock_item.path.to_s) }

    where(:path, :expected_breadcrumb_list) do
      "/ee/tutorials/" | "Learn GitLab with tutorials"
      "/ee/topics/set_up_organization.html" | "Use GitLab &rsaquo; Set up your organization"
      "/ee/user/project/autocomplete_characters.html" | "Use GitLab &rsaquo; Plan and track work &rsaquo; Quick actions &rsaquo; Autocomplete characters"
      "/ee/user/project/settings/import_export_troubleshooting.html" | "Use GitLab &rsaquo; Organize work with projects &rsaquo; Migrate projects using file exports &rsaquo; Troubleshooting"
      "/updog.html" | ""
    end

    with_them do
      it "returns the breadcrumb trail for the given path" do
        expect(subject).to eq(expected_breadcrumb_list)
      end
    end
  end

  describe '#get_release_dates' do
    subject { mock_class.get_release_dates }

    valid_yaml_content = "- version: '18.0'\n  date: '2025-05-15'"
    invalid_yaml_content = "version: '18.0'date: 2025-05-15'"

    it 'returns a JSON array when the YAML is valid' do
      allow(Net::HTTP).to receive(:get_response).and_return(Net::HTTPSuccess.new('1.1', '200', 'OK'))
      allow_any_instance_of(Net::HTTPSuccess).to receive(:body).and_return(valid_yaml_content)
      expect(subject).to be_a(String)
    end

    it 'returns an empty JSON array when the YAML is invalid' do
      allow(Net::HTTP).to receive(:get_response).and_return(Net::HTTPSuccess.new('1.1', '200', 'OK'))
      allow_any_instance_of(Net::HTTPSuccess).to receive(:body).and_return(invalid_yaml_content)
      allow(mock_class).to receive(:warn).with('Error getting release dates - (<unknown>): did not find expected key while parsing a block mapping at line 1 column 1')
      expect(subject).to eq("[]")
    end

    it 'returns an empty JSON array on HTTP error' do
      allow(Net::HTTP).to receive(:get_response).and_return(Net::HTTPServerError.new('1.1', '500', 'Internal Server Error'))
      expect(subject).to eq("[]")
    end

    it 'returns an empty JSON array on other errors' do
      allow(Net::HTTP).to receive(:get_response).and_raise(StandardError.new('Some error message'))
      allow(mock_class).to receive(:warn).with('Error getting release dates - Some error message')
      expect(subject).to eq("[]")
    end
  end
end

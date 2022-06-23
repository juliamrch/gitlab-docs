# frozen_string_literal: true

require 'spec_helper'
require 'nanoc'
require 'helpers/edit_on_gitlab'

RSpec.describe Nanoc::Helpers::EditOnGitLab do
  let(:mock_class) { Class.new { extend Nanoc::Helpers::EditOnGitLab } }
  let(:identifier) { "/content/404.html" }
  let(:content_filename) { "content/404.html" }

  let(:mock_item) do
    item = Struct.new(:identifier, :content_filename)
    item.new(identifier, content_filename)
  end

  subject { mock_class.edit_on_gitlab(mock_item, editor: editor) }

  describe '#edit_on_gitlab' do
    using RSpec::Parameterized::TableSyntax

    where(:identifier, :editor, :expected_url) do
      "/omnibus/index.md"  | :simple | "https://gitlab.com/gitlab-org/omnibus-gitlab/-/blob/master/doc/index.md"
      "/omnibus/index.md"  | :webide | "https://gitlab.com/-/ide/project/gitlab-org/omnibus-gitlab/edit/master/-/doc/index.md"
      "/runner/index.md"   | :simple | "https://gitlab.com/gitlab-org/gitlab-runner/-/blob/main/docs/index.md"
      "/runner/index.md"   | :webide | "https://gitlab.com/-/ide/project/gitlab-org/gitlab-runner/edit/main/-/docs/index.md"
      "/charts/index.md"   | :simple | "https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/doc/index.md"
      "/charts/index.md"   | :webide | "https://gitlab.com/-/ide/project/gitlab-org/charts/gitlab/edit/master/-/doc/index.md"
      "/operator/index.md" | :simple | "https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/blob/master/doc/index.md"
      "/operator/index.md" | :webide | "https://gitlab.com/-/ide/project/gitlab-org/cloud-native/gitlab-operator/edit/master/-/doc/index.md"
      "/ee/user/ssh.md"    | :simple | "https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc/user/ssh.md"
      "/ee/user/ssh.md"    | :webide | "https://gitlab.com/-/ide/project/gitlab-org/gitlab/edit/master/-/doc/user/ssh.md"
      "/content/404.html"  | :simple | "https://gitlab.com/gitlab-org/gitlab-docs/-/blob/main/content/404.html"
      "/content/404.html"  | :webide | "https://gitlab.com/-/ide/project/gitlab-org/gitlab-docs/edit/main/-/content/404.html"
    end

    with_them do
      it 'returns correct url for identifier and editor' do
        expect(subject).to eq(expected_url)
      end
    end

    context 'with unknown editor' do
      let(:editor) { :word }

      it { expect { subject }.to raise_error("Unknown editor: word") }
    end
  end
end

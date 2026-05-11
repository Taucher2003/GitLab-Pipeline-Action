# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabPipelineAction::Step::CloneProject do
  subject(:clone) { instance.execute }

  let(:context) { GitlabPipelineAction::Context.new }
  let(:instance) { described_class.new(context) }
  let(:git) { instance_double(Git::Base) }

  before do
    context.gh_server_url = 'https://github.com'
    context.gh_project = 'owner/repo'
    context.gh_ref = 'refs/heads/main'
    context.gh_sha = 'abc123'
    context.gl_branch_name = 'glpa/main/abc123'

    allow(Git).to receive(:clone).and_return(git)
    allow(git).to receive(:fetch)
    allow(git).to receive(:checkout)
    allow(git).to receive(:branch).and_return(instance_double(Git::Branch, checkout: nil))
  end

  context 'without GH_TOKEN' do
    it 'clones without authentication' do
      clone

      expect(Git).to have_received(:clone).with('https://github.com/owner/repo', anything)
    end
  end

  context 'with GH_TOKEN' do
    before { context.gh_token = 'ghp_secret123' }

    it 'clones with token authentication' do
      clone

      expect(Git).to have_received(:clone).with('https://x-access-token:ghp_secret123@github.com/owner/repo', anything)
    end
  end
end

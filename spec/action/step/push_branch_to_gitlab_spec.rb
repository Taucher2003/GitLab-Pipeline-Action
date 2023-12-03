# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabPipelineAction::Step::PushBranchToGitlab do
  subject(:push) { instance.execute }

  let(:context) { GitlabPipelineAction::Context.new }
  let(:instance) { described_class.new(context) }

  context 'when pushes fail' do
    let(:git) { instance_double(Git::Base) }
    let(:failing_retries) { 4 }

    before do
      allow(git).to receive(:add_remote)
      allow(git).to receive(:push)

      fake_response = instance_double(HTTParty::Response)
      fake_request = instance_double(HTTParty::Request)
      allow(fake_response).to receive_messages(headers: { 'content-type' => 'text/plain' }, to_s: '', code: 404,
                                               request: fake_request)
      allow(fake_request).to receive_messages(base_uri: '', path: '')

      gitlab_client = instance_double(Gitlab::Client)
      allow(context).to receive_messages(git_repository: git, gitlab_client: gitlab_client)

      iteration = 0
      allow(gitlab_client).to receive(:branch) do
        iteration += 1
        raise Gitlab::Error::NotFound, fake_response if iteration <= failing_retries
      end
    end

    it 'retries multiple times', :disable_console do
      push

      expect(git).to have_received(:push).exactly(5).times
    end

    it 'logs failures' do
      expect { push }.to output(
        include(
          'Push failed, 4 retries remaining',
          'Push failed, 3 retries remaining',
          'Push failed, 2 retries remaining',
          'Push failed, 1 retries remaining'
        )
      ).to_stdout
    end

    context 'when retries are exhausted' do
      let(:failing_retries) { 5 }

      it 'raises an error', :disable_console do
        expect do
          push
        end.to raise_error(GitlabPipelineAction::Step::PushBranchToGitlab::PushFailed,
                           'Failed to push to GitLab 5 times')
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabPipelineAction::Step::TriggerPipeline do
  subject(:trigger) { instance.execute }

  let(:context) { GitlabPipelineAction::Context.new }
  let(:instance) { described_class.new(context) }
  let(:gitlab_client) { instance_double(Gitlab::Client) }

  context 'when triggering fails' do
    let(:failing_retries) { 4 }

    before do
      fake_response = instance_double(HTTParty::Response)
      fake_request = instance_double(HTTParty::Request)
      allow(fake_response).to receive_messages(headers: { 'content-type' => 'text/plain' }, to_s: '', code: 400,
                                               request: fake_request, body: "'base' Reference not found")

      allow(fake_request).to receive_messages(base_uri: '', path: '')

      allow(context).to receive_messages(gl_project_id: 1, gl_branch_name: 'glpa/main', gl_pipeline_variables: {},
                                         gitlab_client: gitlab_client)

      fake_pipeline = double
      allow(fake_pipeline).to receive(:web_url).and_return('')

      iteration = 0
      allow(gitlab_client).to receive(:create_pipeline) do
        iteration += 1
        raise Gitlab::Error::BadRequest, fake_response if iteration <= failing_retries
      end.and_return(fake_pipeline)
    end

    it 'retries multiple times', :disable_console do
      trigger

      expect(gitlab_client).to have_received(:create_pipeline).exactly(5).times
    end

    it 'logs failures' do
      expect { trigger }.to output(
        include(
          'Trigger failed, 4 retries remaining',
          'Trigger failed, 3 retries remaining',
          'Trigger failed, 2 retries remaining',
          'Trigger failed, 1 retries remaining'
        )
      ).to_stdout
    end

    context 'when retries are exhausted' do
      let(:failing_retries) { 5 }

      it 'raises an error', :disable_console do
        expect do
          trigger
        end.to raise_error(described_class::TriggerFailed, 'Failed to trigger pipeline in GitLab 5 times')
      end
    end
  end
end

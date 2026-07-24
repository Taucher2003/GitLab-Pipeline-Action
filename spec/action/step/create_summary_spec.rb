# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabPipelineAction::Step::CreateSummary do
  subject(:create_summary) { described_class.new(context).create_summary }

  let(:context) { GitlabPipelineAction::Context.new }
  let(:pipeline) { double }
  let(:detailed_status) { double }
  let(:gitlab_client) { double }
  let(:paginatable_response) { double }
  let(:job) { double }

  before do
    allow(context).to receive_messages(gl_project_id: 1, gl_pipeline: pipeline, gitlab_client: gitlab_client)
    allow(pipeline).to receive_messages(web_url: 'some_web_url', duration: 50, detailed_status: detailed_status, id: 1)
    allow(detailed_status).to receive(:text).and_return('Passed')
    allow(gitlab_client).to receive(:pipeline_jobs).and_return(paginatable_response)
    allow(paginatable_response).to receive(:auto_paginate).and_return([job])
    allow(job).to receive_messages(id: 1, name: 'build', web_url: 'some_job_url')
    allow(gitlab_client).to receive(:job_trace).and_return(
      <<~TRACE
        Some job output
        And more job output
        \e[0Ksection_start:1560896352:glpa_summary\r\e[0KTitle of the GLPA Summary
        Content of the GLPA summary
        \e[0Ksection_end:1560896353:glpa_summary\r\e[0K
        Job output after the summary
      TRACE
    )
  end

  it 'includes the pipeline link' do
    expect(create_summary).to include('Link to pipeline: some_web_url')
  end

  it 'includes the pipeline status' do
    expect(create_summary).to include('Status: Passed')
  end

  it 'includes the pipeline duration' do
    expect(create_summary).to include('Duration: 50 seconds')
  end

  it 'includes the job summary' do
    expect(create_summary).to include(
      <<~DESC
        ## Job summaries

        ### [build](some_job_url)

        Content of the GLPA summary
      DESC
    )
  end

  context 'when no jobs have a summary' do
    before do
      allow(gitlab_client).to receive(:job_trace).and_return(
        <<~TRACE
          Some job output
          And more job output
      TRACE
      )
    end

    it 'does not include the job summary header' do
      expect(create_summary).not_to include('Job summaries')
    end
  end

  context 'when jobs have a summary and timestamps are enabled' do
    before do
      allow(gitlab_client).to receive(:job_trace).and_return(
        <<~TRACE
          2024-09-27T22:55:05.708980Z 00O \e[0Ksection_start:1560896352:glpa_summary\r\e[0KTitle of the GLPA Summary
          2024-09-27T22:55:05.708980Z 00O Content of timestamped summary
          2024-09-27T22:55:05.708980Z 00O \e[0Ksection_end:1560896353:glpa_summary\r\e[0K
        TRACE
      )
    end

    it 'includes the job summary' do
      expect(create_summary).to include(
        <<~DESC
          ## Job summaries

          ### [build](some_job_url)

          Content of timestamped summary
        DESC
      )
    end
  end

  context 'when no jobs have a trace' do
    before do
      allow(gitlab_client).to receive(:job_trace).and_return(nil)
    end

    it 'does not include the job summary header' do
      expect(create_summary).not_to include('Job summaries')
    end
  end

  describe 'job trace retry behaviour' do
    subject(:create_summary_instance) { described_class.new(context) }

    let(:fake_response) { instance_double(HTTParty::Response) }
    let(:fake_request) { instance_double(HTTParty::Request) }

    before do
      allow(fake_response).to receive_messages(headers: { 'content-type' => 'text/plain' }, to_s: '', code: 500,
                                               request: fake_request, body: 'Internal Server Error')
      allow(fake_request).to receive_messages(base_uri: '', path: '')
      allow_any_instance_of(described_class).to receive(:sleep) # rubocop:disable RSpec/AnyInstance
    end

    context 'when job_trace succeeds on first attempt' do
      before do
        allow(gitlab_client).to receive(:job_trace).and_return('trace output')
      end

      it 'returns the trace without retrying' do
        create_summary_instance.create_summary
        expect(gitlab_client).to have_received(:job_trace).once
      end
    end

    context 'when job_trace fails with a retryable error then succeeds' do
      before do
        call_count = 0
        allow(gitlab_client).to receive(:job_trace) do
          call_count += 1
          raise Gitlab::Error::InternalServerError, fake_response if call_count < 3

          'trace output'
        end
      end

      it 'retries and returns the trace' do
        create_summary_instance.create_summary
        expect(gitlab_client).to have_received(:job_trace).exactly(3).times
      end
    end

    context 'when job_trace fails with BadGateway then succeeds' do
      before do
        call_count = 0
        allow(gitlab_client).to receive(:job_trace) do
          call_count += 1
          raise Gitlab::Error::BadGateway, fake_response if call_count == 1

          'trace output'
        end
      end

      it 'retries and returns the trace' do
        create_summary_instance.create_summary
        expect(gitlab_client).to have_received(:job_trace).twice
      end
    end

    context 'when job_trace fails with ServiceUnavailable then succeeds' do
      before do
        call_count = 0
        allow(gitlab_client).to receive(:job_trace) do
          call_count += 1
          raise Gitlab::Error::ServiceUnavailable, fake_response if call_count == 1

          'trace output'
        end
      end

      it 'retries and returns the trace' do
        create_summary_instance.create_summary
        expect(gitlab_client).to have_received(:job_trace).twice
      end
    end

    context 'when job_trace fails with ConnectionTimedOut then succeeds' do
      before do
        call_count = 0
        allow(gitlab_client).to receive(:job_trace) do
          call_count += 1
          raise Gitlab::Error::ConnectionTimedOut, fake_response if call_count == 1

          'trace output'
        end
      end

      it 'retries and returns the trace' do
        create_summary_instance.create_summary
        expect(gitlab_client).to have_received(:job_trace).twice
      end
    end

    context 'when job_trace fails with a retryable error more than the max attempts' do
      before do
        allow(gitlab_client).to receive(:job_trace).and_raise(Gitlab::Error::InternalServerError, fake_response)
      end

      it 'raises the error after exhausting retries' do
        expect { create_summary_instance.create_summary }.to raise_error(Gitlab::Error::InternalServerError)
      end

      it 'attempts the configured number of retries' do
        begin
          create_summary_instance.create_summary
        rescue Gitlab::Error::InternalServerError
          # expected
        end

        expect(gitlab_client).to have_received(:job_trace).exactly(6).times
      end
    end

    context 'when job_trace fails with a non-retryable error' do
      before do
        allow(gitlab_client).to receive(:job_trace).and_raise(Gitlab::Error::NotFound, fake_response)
      end

      it 'raises immediately without retrying' do
        expect { create_summary_instance.create_summary }.to raise_error(Gitlab::Error::NotFound)
      end

      it 'does not retry' do
        begin
          create_summary_instance.create_summary
        rescue Gitlab::Error::NotFound
          # expected
        end

        expect(gitlab_client).to have_received(:job_trace).once
      end
    end
  end
end

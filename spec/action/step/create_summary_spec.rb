# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabPipelineAction::Step::CreateSummary do
  subject(:create_summary) { described_class.new(context).create_summary }

  let(:context) { GitlabPipelineAction::Context.new }
  let(:pipeline) { double }
  let(:detailed_status) { double }
  let(:gitlab_client) { double }
  let(:job) { double }

  before do
    allow(context).to receive_messages(gl_project_id: 1, gl_pipeline: pipeline, gitlab_client: gitlab_client)
    allow(pipeline).to receive_messages(web_url: 'some_web_url', duration: 50, detailed_status: detailed_status, id: 1)
    allow(detailed_status).to receive(:text).and_return('Passed')
    allow(gitlab_client).to receive(:pipeline_jobs).and_return([job])
    allow(job).to receive_messages(id: 1, name: 'build')
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

        ### build

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

          ### build

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
end

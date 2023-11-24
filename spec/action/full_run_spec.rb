# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Full run', :require_gitlab do # rubocop:disable RSpec/DescribeClass
  subject(:execute) { GitlabPipelineAction::Entrypoint.new.execute(context) }

  let(:context) { GitlabPipelineAction::Context.new }

  it 'runs without error', :disable_console do
    expect { execute }.not_to raise_error
  end

  it 'does not output job traces by default' do
    expect { execute }.to output(include('GitlabPipelineAction::Step::ShowJobLogs: skipped')).to_stdout
  end

  context 'when SHOW_JOB_LOGS is set to failures' do
    stub_env('INPUT_SHOW_JOB_LOGS', 'failures')

    it 'only outputs job traces of failed jobs' do
      expect { execute }.to output(
        include("'failing-job' in stage 'test' (failed)")
          .and(not_include("'job' in stage 'test' (success)"))
      ).to_stdout
    end
  end

  context 'when SHOW_JOB_LOGS is set to all' do
    stub_env('INPUT_SHOW_JOB_LOGS', 'all')

    it 'outputs job traces of all jobs' do
      expect { execute }.to output(
        include(
          "'failing-job' in stage 'test' (failed)",
          "'job' in stage 'test' (success)",
          "'job-with-commands' in stage 'test' (success)"
        )
      ).to_stdout
    end
  end

  context 'when setting a variable for the pipeline' do
    stub_env('GLPA_SOME_VARIABLE', 'A test value for the variable')
    stub_env('INPUT_SHOW_JOB_LOGS', 'all')

    it 'passes the variable to the pipeline' do
      expect { execute }.to output(
        include('A test value for the variable')
      ).to_stdout
    end
  end

  it 'creates the summary', :disable_console do
    execute

    expect(File.read(context.gh_step_summary_path)).to include(
      '# GitLab Pipeline Action',
      '## General information',
      "Link to pipeline: #{context.gl_pipeline.web_url}",
      "Status: #{context.gl_pipeline.detailed_status.text} \\",
      '## Job summaries',
      'job-with-summary',
      "This line should be part of the summary\n" \
      'this one as well'
    )
  end

  it 'creates the output', :disable_console do
    execute

    expect(File.read(context.gh_step_output_path)).to match(
      %r{^SUMMARY_TEXT<<(.+)\n[\s\S]+/pipelines/(\d+)\n[\s\S]+\1\nPIPELINE_ID=\2$}
    )
  end
end

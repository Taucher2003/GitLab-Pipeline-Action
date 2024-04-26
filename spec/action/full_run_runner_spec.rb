# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Full run (Runner)', :require_gitlab do # rubocop:disable RSpec/DescribeClass
  subject(:execute) { GitlabPipelineAction::Task::Runner.new.execute(context) }

  let(:context) { GitlabPipelineAction::Context.new }

  let(:project_id) { ENV.fetch('INPUT_GL_PROJECT_ID').to_i }

  it 'runs all pipelines', :aggregate_failures, :disable_console do
    first_pipeline_id = Gitlab.create_pipeline(project_id, 'master').id
    second_pipeline_id = Gitlab.create_pipeline(project_id, 'master').id

    execute

    expect(Gitlab.pipeline(project_id, first_pipeline_id).status).to eq('success')
    expect(Gitlab.pipeline(project_id, second_pipeline_id).status).to eq('success')
  end

  it 'runs without problems if no processable pipelines exist', :disable_console do
    expect { execute }.not_to raise_error
  end
end

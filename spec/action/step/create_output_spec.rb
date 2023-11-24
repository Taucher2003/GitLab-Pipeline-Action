# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabPipelineAction::Step::CreateOutput do
  subject(:create_output) { instance.create_output }

  let(:context) { GitlabPipelineAction::Context.new }
  let(:instance) { described_class.new(context) }

  before do
    pipeline = double

    allow(context).to receive(:gl_pipeline).and_return(pipeline)
    allow(pipeline).to receive(:id).and_return(1)
    allow(instance).to receive(:read_summary).and_return('Some summary text')
  end

  it 'contains the summary' do
    expect(create_output).to match(/^SUMMARY_TEXT<<([^\n]+)\nSome summary text\n\1$/)
  end

  it 'contains the pipeline id' do
    expect(create_output).to match(/^PIPELINE_ID=1$/)
  end
end

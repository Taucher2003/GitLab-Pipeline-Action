# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabPipelineAction::Step::PrepareContext do
  let(:context) { GitlabPipelineAction::Context.new }
  let(:step) { described_class.new(context) }

  before do
    step.execute
  end

  it 'takes data from default variables', :aggregate_failures do
    expect(context.gh_sha).to eq('master')
    expect(context.gh_ref).to eq('refs/heads/master')
    expect(context.gl_branch_name).to eq('glpa/master')
  end

  context 'when ref variables are overridden' do
    stub_env('INPUT_OVERRIDE_GITHUB_SHA', '123')
    stub_env('INPUT_OVERRIDE_GITHUB_REF', 'refs/heads/blub')
    stub_env('INPUT_OVERRIDE_GITHUB_REF_NAME', 'blub')

    it 'takes data from the override', :aggregate_failures do
      expect(context.gh_sha).to eq('123')
      expect(context.gh_ref).to eq('refs/heads/blub')
      expect(context.gl_branch_name).to eq('glpa/blub')
    end
  end
end

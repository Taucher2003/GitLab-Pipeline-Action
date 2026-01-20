# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabPipelineAction::Helper::Github do
  # rubocop:disable RSpec/Output
  it '#warning writes the correct format' do
    expect do
      described_class.warning('Some warning message')
    end.to output(
      "::warning::Some warning message\n"
    ).to_stdout
  end

  it '#with_group writes the correct format' do
    expect do
      described_class.with_group('Some group name') do
        puts 'Some message'
      end
    end.to output(
      "::group::Some group name\n" \
      "Some message\n" \
      "::endgroup::\n"
    ).to_stdout
  end

  it '#stop_commands writes the correct format' do
    allow(SecureRandom).to receive(:hex).and_return('Some random value')

    expect do
      described_class.stop_commands do
        puts 'Some message'
      end
    end.to output(
      "::stop-commands::Some random value\n" \
      "Some message\n" \
      "::Some random value::\n"
    ).to_stdout
  end
  # rubocop:enable RSpec/Output
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabPipelineAction::Helper::Env do
  stub_env('TEST_A', 'value_a')
  stub_env('TEST_B', 'value_b')
  stub_env('TEST_C', 'value_c')
  stub_env('TEST_D', '')

  context 'when used with a single argument' do
    it 'returns the env value' do
      expect(described_class.fetch('TEST_A')).to eq('value_a')
    end

    it 'returns the env value if default is given' do
      expect(described_class.fetch('TEST_A', default: 'value_default')).to eq('value_a')
    end

    it 'returns nil if env var does not exist' do
      expect(described_class.fetch('BLUB')).to be_nil
    end

    it 'returns default if env var does not exist' do
      expect(described_class.fetch('BLUB', default: 'value_default')).to eq('value_default')
    end

    it 'returns the default if only a blank value exists' do
      expect(described_class.fetch('TEST_D', default: 'value_default')).to eq('value_default')
    end

    it 'returns the blank value if allow_blank is set' do
      expect(described_class.fetch('TEST_D', default: 'value_default', allow_blank: true)).to eq('')
    end
  end

  context 'when used with multiple arguments' do
    it 'returns the first env var' do
      expect(described_class.fetch('TEST_A', 'TEST_B', 'TEST_C')).to eq('value_a')
    end

    it 'returns the first env var that exists' do
      expect(described_class.fetch('BLUB', 'TEST_B', 'TEST_C')).to eq('value_b')
    end

    it 'returns the first env var that exists when default is given' do
      expect(described_class.fetch('BLUB', 'TEST_B', 'TEST_C', default: 'value_default')).to eq('value_b')
    end

    it 'returns nil if no env var exists' do
      expect(described_class.fetch('BLUB', 'BLAB', 'BLUB_BLAB')).to be_nil
    end

    it 'returns default if no env var exists' do
      expect(described_class.fetch('BLUB', 'BLAB', 'BLUB_BLAB', default: 'value_default')).to eq('value_default')
    end
  end
end

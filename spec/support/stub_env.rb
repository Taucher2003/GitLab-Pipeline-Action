# frozen_string_literal: true

module StubEnv
  def stub_env(key, value)
    around do |example|
      original_value = ENV.fetch(key, nil)
      ENV[key] = value
      example.run
    ensure
      ENV[key] = original_value
    end
  end
end

RSpec.configure do |config|
  config.extend StubEnv
end

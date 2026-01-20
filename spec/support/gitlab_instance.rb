# frozen_string_literal: true

gitlab_not_running = false

RSpec.configure do |config|
  Gitlab.configure do |c|
    c.endpoint = ENV.fetch('GITLAB_BASE_URL', 'http://127.0.0.1:8080/api/v4')
    c.private_token = ENV.fetch('GITLAB_TOKEN', 'TEST1234567890123456')
  end

  begin
    puts Gitlab.version.to_h # rubocop:disable RSpec/Output
  rescue Errno::ECONNREFUSED
    gitlab_not_running = true
  end

  config.around(:each, :require_gitlab) do |example|
    if gitlab_not_running
      skip 'GitLab is not running'
      next
    end

    example.run
  end
end

# frozen_string_literal: true

RSpec.configure do
  ENV['GITHUB_REPOSITORY'] = 'Taucher2003/GitLab-Pipeline-Action'
  ENV['GITHUB_SHA'] = 'master'
  ENV['GITHUB_REF'] = 'refs/heads/master'
  ENV['GITHUB_REF_NAME'] = 'master'
  ENV['GITHUB_SERVER_URL'] = 'https://github.com'

  ENV['INPUT_GL_SERVER_URL'] = ENV.fetch('GITLAB_BASE_URL', 'http://127.0.0.1:8080')
  ENV['INPUT_GL_SERVER_URL_FOR_RUNNER'] = ENV.fetch('GITLAB_BASE_URL_FOR_RUNNER', ENV.fetch('INPUT_GL_SERVER_URL', nil))
  ENV['INPUT_GL_PROJECT_ID'] = ENV.fetch('GITLAB_PROJECT_ID', '1000')
  ENV['INPUT_GL_RUNNER_TOKEN'] = ENV.fetch('GITLAB_RUNNER_TOKEN', 'some_long_runner_token')
  ENV['INPUT_GL_API_TOKEN'] = ENV.fetch('GITLAB_TOKEN', 'TEST1234567890123456')
end

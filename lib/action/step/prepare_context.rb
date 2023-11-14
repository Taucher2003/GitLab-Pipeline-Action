# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class PrepareContext < Base
      def execute
        context.gh_project = ENV.fetch('GITHUB_REPOSITORY', nil)
        context.gh_sha = ENV.fetch('GITHUB_SHA', nil)
        context.gh_ref = ENV.fetch('GITHUB_REF', nil)
        context.gh_ref_name = ENV.fetch('GITHUB_REF_NAME', nil)
        context.gh_server_url = ENV.fetch('GITHUB_SERVER_URL', nil)

        context.gl_server_url = ENV.fetch('INPUT_GL_SERVER_URL', nil)
        context.gl_project_id = ENV.fetch('INPUT_GL_PROJECT_ID', nil)
        context.gl_runner_token = ENV.fetch('INPUT_GL_RUNNER_TOKEN', nil)
        context.gl_api_token = ENV.fetch('INPUT_GL_API_TOKEN', nil)

        context.git_path = "/tmp/repo/#{SecureRandom.hex}"

        config = {}
        config[:endpoint] = "#{context.gl_server_url}/api/v4"
        config[:private_token] = if context.gl_api_token.nil?
                                   ''
                                 else
                                   context.gl_api_token
                                 end

        context.gitlab_client = Gitlab.client(config)
      end
    end
  end
end

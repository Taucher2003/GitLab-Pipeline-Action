# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class PrepareContext < Base
      def execute
        context.gh_project = env.fetch('GITHUB_REPOSITORY')
        context.gh_sha = env.fetch('INPUT_OVERRIDE_GITHUB_SHA', 'GITHUB_SHA')
        context.gh_ref = env.fetch('INPUT_OVERRIDE_GITHUB_REF', 'GITHUB_REF')
        context.gh_server_url = env.fetch('GITHUB_SERVER_URL')

        context.gl_branch_name = "glpa/#{env.fetch('INPUT_OVERRIDE_GITHUB_REF_NAME', 'GITHUB_REF_NAME')}"

        context.gl_server_url = env.fetch('INPUT_GL_SERVER_URL')
        context.gl_server_url_for_runner = env.fetch(
          'INPUT_GL_SERVER_URL_FOR_RUNNER', # intentionally undocumented
          default: context.gl_server_url
        )
        context.gl_project_id = env.fetch('INPUT_GL_PROJECT_ID')
        context.gl_runner_token = env.fetch('INPUT_GL_RUNNER_TOKEN')
        context.gl_api_token = env.fetch('INPUT_GL_API_TOKEN')
        context.gl_pipeline_variables = ENV.select { |key| key.start_with?('GLPA_') }
                                           .transform_keys { |key| key.delete_prefix('GLPA_') }

        context.gl_show_job_logs = env.fetch('INPUT_SHOW_JOB_LOGS')&.to_sym

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

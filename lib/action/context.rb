# frozen_string_literal: true

module GitlabPipelineAction
  class Context
    attr_accessor :gh_project, :gh_sha, :gh_ref, :gh_server_url,
                  :gl_server_url, :gl_project_id, :gl_project_path, :gl_runner_token,
                  :gl_api_token, :gl_pipeline, :gl_branch_name,
                  :git_repository, :git_path,
                  :gitlab_client,
                  :docker_runner_container
  end
end

# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class PushBranchToGitlab < Base
      def execute
        context.git_repository.add_remote(GITLAB_REMOTE, gitlab_remote_url)
        context.git_repository.push(GITLAB_REMOTE, context.gh_ref, push_option: ['ci.skip'])
      end

      private

      def gitlab_remote_url
        insert_authorization "#{context.gl_server_url}/#{context.gl_project_path}.git"
      end

      def insert_authorization(url)
        url.gsub(%r{(https?)://}, "\\1://gitlab-token:#{context.gl_api_token}@")
      end
    end
  end
end

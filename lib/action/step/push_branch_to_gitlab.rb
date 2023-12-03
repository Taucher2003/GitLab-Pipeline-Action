# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class PushBranchToGitlab < Base
      PushFailed = Class.new(StandardError)
      MAX_PUSH_RETRIES = 5

      def execute
        context.git_repository.add_remote(GITLAB_REMOTE, gitlab_remote_url)

        MAX_PUSH_RETRIES.times do |iteration|
          context.git_repository.push(GITLAB_REMOTE, context.gl_branch_name, push_option: ['ci.skip'])

          begin
            context.gitlab_client.branch(context.gl_project_id, context.gl_branch_name)
            return # rubocop:disable Lint/NonLocalExitFromIterator -- this is intended
          rescue Gitlab::Error::NotFound
            # ignore
          end

          puts "Push failed, #{MAX_PUSH_RETRIES - iteration - 1} retries remaining"
        end

        raise PushFailed, "Failed to push to GitLab #{MAX_PUSH_RETRIES} times"
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

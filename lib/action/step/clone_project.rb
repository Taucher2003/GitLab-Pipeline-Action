# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class CloneProject < Base
      def execute
        context.git_repository = Git.clone(clone_url, context.git_path)

        context.git_repository.fetch('origin', ref: context.gh_ref)
        context.git_repository.checkout(context.gh_sha)
        context.git_repository.branch(context.gl_branch_name).checkout
      end

      private

      def clone_url
        url = "#{context.gh_server_url}/#{context.gh_project}"
        return url if context.gh_token.nil?

        url.gsub(%r{(https?)://}, "\\1://x-access-token:#{context.gh_token}@")
      end
    end
  end
end

# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class CloneProject < Base
      def execute
        context.git_repository = Git.clone(
          "#{context.gh_server_url}/#{context.gh_project}",
          context.git_path
        )

        context.git_repository.fetch('origin', ref: context.gh_ref)
        context.git_repository.checkout(context.gh_sha)
        context.git_repository.branch(context.gl_branch_name).checkout
      end
    end
  end
end

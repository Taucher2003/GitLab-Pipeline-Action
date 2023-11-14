# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class RemoveBranchFromGitlab < Base
      def execute
        context.gitlab_client.delete_branch(context.gl_project_id, context.gh_ref_name)
      end
    end
  end
end

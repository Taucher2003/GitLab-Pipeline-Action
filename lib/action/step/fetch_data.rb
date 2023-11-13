# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class FetchData < Base
      def execute
        project = context.gitlab_client.project(context.gl_project_id)

        context.gl_project_path = project.path_with_namespace
      end
    end
  end
end

# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class TriggerPipeline < Base
      def execute
        context.gl_pipeline = context.gitlab_client.create_pipeline(
          context.gl_project_id,
          context.gl_branch_name,
          context.gl_pipeline_variables
        )

        puts "Triggered: #{context.gl_pipeline.web_url}"
      end
    end
  end
end

# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class WaitForPipeline < Base
      def execute
        pipeline = context.gl_pipeline
        GitlabPipelineAction::PipelineAwaiter.new(pipeline, context.gitlab_client).wait!
      rescue GitlabPipelineAction::PipelineAwaiter::PipelineFinishedUnsuccessful
        # ignore
      ensure
        context.gl_pipeline = context.gitlab_client.pipeline(pipeline.project_id, pipeline.id)
      end
    end
  end
end

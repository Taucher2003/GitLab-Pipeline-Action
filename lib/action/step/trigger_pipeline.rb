# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class TriggerPipeline < Base
      TriggerFailed = Class.new(StandardError)
      MAX_TRIGGER_RETRIES = 5

      def execute
        MAX_TRIGGER_RETRIES.times do |iteration|
          context.gl_pipeline = context.gitlab_client.create_pipeline(
            context.gl_project_id,
            context.gl_branch_name,
            context.gl_pipeline_variables
          )
          puts "Triggered: #{context.gl_pipeline.web_url}"
          return # rubocop:disable Lint/NonLocalExitFromIterator -- this is intended
        rescue Gitlab::Error::BadRequest => e
          puts e.full_message(order: :top)
          puts "Trigger failed, #{MAX_TRIGGER_RETRIES - iteration - 1} retries remaining"
          sleep 1
        end

        raise TriggerFailed, "Failed to trigger pipeline in GitLab #{MAX_TRIGGER_RETRIES} times"
      end
    end
  end
end

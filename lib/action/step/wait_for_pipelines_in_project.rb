# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class WaitForPipelinesInProject < Base
      PipelinesTimedOut = Class.new(StandardError)

      INTERVAL = 10 # seconds
      MAX_DURATION = 3600 * 3 # 3 hours

      attr_reader :start_time

      def execute
        @start_time = Time.now.to_i

        puts 'Waiting for processable pipelines to finish'
        (MAX_DURATION / INTERVAL).times do
          sleep INTERVAL

          unless processable_pipelines?
            puts
            puts "Processable pipelines finished after #{duration} minutes!"
            return
          end

          print '.'
          $stdout.flush
        end

        puts
        puts "Waiting for processable pipelines timed out after #{duration} minutes!"
        raise PipelinesTimedOut, "Waiting for processable pipelines timed out after #{duration} minutes!"
      end

      def duration
        (Time.now.to_i - start_time) / 60
      end

      def processable_pipelines?
        running_pipelines? || pending_pipelines?
      end

      def running_pipelines?
        context.gitlab_client.pipelines(context.gl_project_id, scope: :running).any?
      end

      def pending_pipelines?
        context.gitlab_client.pipelines(context.gl_project_id, scope: :pending).any?
      end
    end
  end
end

# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class StopRunner < Base
      def execute
        context.docker_runner_container.kill(signal: 'SIGQUIT')
        context.docker_runner_container.attach
      rescue Docker::Error::TimeoutError
        # ignore
      ensure
        context.docker_runner_container.delete
      end

      def skip?
        context.gl_runner_token.nil?
      end
    end
  end
end

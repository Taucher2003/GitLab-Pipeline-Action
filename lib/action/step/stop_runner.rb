# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class StopRunner < Base
      def execute(retries = 0)
        context.docker_runner_container.kill(signal: 'SIGQUIT')
        context.docker_runner_container.attach
      rescue Docker::Error::TimeoutError, Docker::Error::ConflictError
        # ignore
      ensure
        delete_container(retries)
      end

      def delete_container(retries)
        context.docker_runner_container.delete
      rescue Docker::Error::ConflictError
        if retries < 3
          execute(retries + 1)
        else
          context.docker_runner_container.delete(force: true)
        end
      end

      def skip?
        context.gl_runner_token.nil?
      end
    end
  end
end

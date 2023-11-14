# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class StartRunner < Base
      GITLAB_RUNNER_IMAGE = 'gitlab/gitlab-runner:v16.5.0'

      def execute
        Docker::Image.create('fromImage' => GITLAB_RUNNER_IMAGE)
        container = Docker::Container.create(
          'Image' => GITLAB_RUNNER_IMAGE,
          'HostConfig' => {
            'Binds' => [
              '/var/run/docker.sock:/var/run/docker.sock:ro'
            ],
            'NetworkMode' => 'host'
          }
        )

        container.start
        container.exec([
                         'gitlab-runner', 'register',
                         '--non-interactive',
                         '--url', context.gl_server_url,
                         '--token', context.gl_runner_token,
                         '--executor', 'docker',
                         '--docker-image', 'alpine:latest'
                       ])

        context.docker_runner_container = container
      end

      def skip?
        context.gl_runner_token.nil?
      end
    end
  end
end

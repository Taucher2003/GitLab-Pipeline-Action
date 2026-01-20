# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class StartRunner < Base
      RunnerInvalid = Class.new(StandardError)

      GITLAB_RUNNER_IMAGE = 'registry.gitlab.com/gitlab-org/gitlab-runner:v18.8.0'

      def execute
        runner_config_template_path = "#{File.expand_path('../config', __dir__)}/gitlab_runner_config_template.toml"
        runner_config_template = File.read(runner_config_template_path)

        pull_image unless Docker::Image.exist?(GITLAB_RUNNER_IMAGE)
        container = Docker::Container.create(
          'Image' => GITLAB_RUNNER_IMAGE,
          'HostConfig' => {
            'Binds' => [
              '/var/run/docker.sock:/var/run/docker.sock:ro'
            ],
          }
        )

        container.store_file('/tmp/runner_config_template.toml', runner_config_template)

        container.start
        _, register_output, register_exit_code = container.exec(
          [
            'gitlab-runner', 'register',
            '--non-interactive',
            '--template-config', '/tmp/runner_config_template.toml',
            '--url', context.gl_server_url_for_runner,
            '--token', context.gl_runner_token,
            '--executor', 'docker',
            '--docker-image', 'alpine:latest'
          ]
        )

        _, verify_output, verify_exit_code = container.exec(%w[gitlab-runner verify])

        if !register_exit_code.zero? || !verify_exit_code.zero?
          container.stop
          container.delete
          puts '=== REGISTER'
          puts register_output
          puts '=== VERIFY'
          puts verify_output
          raise RunnerInvalid
        end

        context.docker_runner_container = container
      end

      def skip?
        context.gl_runner_token.nil?
      end

      private

      def pull_image
        remaining_attempts = 5
        begin
          puts "Pulling #{GITLAB_RUNNER_IMAGE} (remaining attempts: #{remaining_attempts})"
          Docker::Image.create('fromImage' => GITLAB_RUNNER_IMAGE)
        rescue Docker::Error::DockerError => e
          puts e.full_message(order: :top)
          retry if (remaining_attempts -= 1).positive?
        end
      end
    end
  end
end

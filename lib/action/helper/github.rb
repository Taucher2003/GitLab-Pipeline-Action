# frozen_string_literal: true

module GitlabPipelineAction
  module Helper
    module Github
      module_function

      def warning(message)
        puts "::warning::#{message}"
      end

      def with_group(name)
        puts "::group::#{name}"
        yield
        puts '::endgroup::'
      end

      def stop_commands
        token = SecureRandom.hex
        puts "::stop-commands::#{token}"
        yield
        puts "::#{token}::"
      end
    end
  end
end

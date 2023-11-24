# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class CreateOutput < Base
      def execute
        File.write context.gh_step_output_path, create_output
      end

      def create_output
        summary_delimiter = "#{SecureRandom.hex}#{SecureRandom.hex}"

        <<~OUTPUT
          SUMMARY_TEXT<<#{summary_delimiter}
          #{read_summary}
          #{summary_delimiter}
          PIPELINE_ID=#{context.gl_pipeline.id}
        OUTPUT
      end

      def read_summary
        File.read context.gh_step_summary_path
      end

      def skip?
        !File.exist? context.gh_step_summary_path
      end
    end
  end
end

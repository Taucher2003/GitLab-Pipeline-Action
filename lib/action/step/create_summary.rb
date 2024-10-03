# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class CreateSummary < Base
      TIMESTAMP_REGEX = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}Z/

      def execute
        File.write context.gh_step_summary_path, create_summary
      end

      def create_summary
        base_description = <<~DESC
          # GitLab Pipeline Action

          ## General information

          Link to pipeline: #{context.gl_pipeline.web_url}

          Status: #{context.gl_pipeline.detailed_status.text} \\
          Duration: #{format_time}
        DESC

        summaries = job_summaries

        return base_description if summaries.empty?

        <<~DESC
          #{base_description}

          ## Job summaries

          #{summaries.join("\n\n")}
        DESC
      end

      def format_time
        duration = context.gl_pipeline.duration
        return 0 if duration.nil?

        if duration < 60
          "#{duration} seconds"
        else
          "#{duration / 60} minutes"
        end
      end

      def job_summaries
        job_traces.map do |elem|
          summary = extract_summary(elem[:trace])
          next if summary.nil?

          <<~DESC
            ### #{elem[:job].name}

            #{summary}
          DESC
        end.compact
      end

      def extract_summary(trace)
        return if trace.nil?

        lines_after_summary_start = trace.lines
                                         .map(&:strip)
                                         .map(&method(:remove_timestamp))
                                         .drop_while { |line| line !~ /^\e\[0Ksection_start:\d+:glpa_summary/ }
                                         .drop(1)
        summary_lines = lines_after_summary_start.take_while { |line| line !~ /^\e\[0Ksection_end:\d+:glpa_summary/ }

        if summary_lines.empty?
          nil
        else
          summary_lines.join("\n")
        end
      end

      def job_traces
        context.gitlab_client
               .pipeline_jobs(context.gl_project_id, context.gl_pipeline.id)
               .map { |job| { job: job, trace: context.gitlab_client.job_trace(context.gl_project_id, job.id) } }
      end

      def remove_timestamp(line)
        if line =~ TIMESTAMP_REGEX
          line[32..]
        else
          line
        end
      end
    end
  end
end

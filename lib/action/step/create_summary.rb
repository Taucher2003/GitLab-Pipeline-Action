# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class CreateSummary < Base
      TIMESTAMP_REGEX = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}Z/
      JOB_TRACE_RETRY_ATTEMPTS = 5
      RETRY_ON_ERRORS = [
        Gitlab::Error::InternalServerError,
        Gitlab::Error::BadGateway,
        Gitlab::Error::ServiceUnavailable,
        Gitlab::Error::ConnectionTimedOut
      ].freeze

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
            ### [#{elem[:job].name}](#{elem[:job].web_url})

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
               .auto_paginate
               .map { |job| { job: job, trace: job_trace(job.id) } }
      end

      def job_trace(job_id)
        attempt = 0

        begin
          attempt += 1
          context.gitlab_client.job_trace(context.gl_project_id, job_id)
        rescue *RETRY_ON_ERRORS => e
          raise e if attempt > JOB_TRACE_RETRY_ATTEMPTS

          sleep 1
          retry
        end
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

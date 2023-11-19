# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class ShowJobLogs < Base
      VARIANTS = {
        all: ->(_) { true },
        failures: ->(job) { job.status == 'failed' },
      }.freeze

      def execute
        unless VARIANTS.key?(context.gl_show_job_logs)
          github.warning 'Invalid option for SHOW_JOB_LOGS'
          return
        end

        jobs = context.gitlab_client
                      .pipeline_jobs(context.gl_project_id, context.gl_pipeline.id)
                      .select(&VARIANTS[context.gl_show_job_logs])
                      .sort_by { |job| job.id.to_i }

        jobs.each do |job|
          github.with_group "'#{job.name}' in stage '#{job.stage}' (#{job.status})" do
            github.stop_commands do
              puts context.gitlab_client.job_trace(context.gl_project_id, job.id)
            end
          end
        end
      end

      def skip?
        context.gl_show_job_logs.nil? || context.gl_show_job_logs == :none
      end
    end
  end
end

# frozen_string_literal: true

module GitlabPipelineAction
  class PipelineAwaiter
    PipelineFinishedUnsuccessful = Class.new(StandardError)
    PipelineFailed = Class.new(PipelineFinishedUnsuccessful)
    PipelineTimedOut = Class.new(PipelineFinishedUnsuccessful)

    INTERVAL = 10 # seconds
    MAX_DURATION = 3600 * 3 # 3 hours

    def initialize(pipeline, gitlab_client)
      @pipeline = pipeline
      @gitlab_client = gitlab_client
      @start_time = Time.now.to_i
    end

    def wait!
      (MAX_DURATION / INTERVAL).times do
        case status
        when :created, :pending, :running, :scheduled, :waiting_for_resource
          print '.'
          sleep INTERVAL
        when :success
          puts
          puts "Pipeline succeeded in #{duration} minutes!"
          return
        else
          puts
          puts "Pipeline #{status} in #{duration} minutes!"
          raise PipelineFailed, 'Pipeline did not succeed!'
        end

        $stdout.flush
      end

      puts "Waiting for pipeline timed out in #{duration} minutes!"
      raise PipelineTimedOut, "Pipeline timed out after waiting for #{duration} minutes!"
    end

    def duration
      (Time.now.to_i - start_time) / 60
    end

    def status
      retries = 0

      begin
        load_pipeline.status.to_sym
      rescue Gitlab::Error::Error => e
        puts "Ignoring the following error: #{e}"
        # Ignore GitLab API hiccups. If GitLab is really down, we'll hit the job
        # timeout anyway.
        :running
      rescue OpenSSL::SSL::SSLError => e
        retries += 1
        raise e unless retries <= 5

        retry
      end
    end

    private

    def load_pipeline
      @pipeline = gitlab_client.pipeline(pipeline.project_id, pipeline.id)
    end

    attr_reader :gitlab_client, :start_time, :pipeline
  end
end

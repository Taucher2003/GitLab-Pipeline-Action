# frozen_string_literal: true

module GitlabPipelineAction
  class Entrypoint
    STEPS = [
      GitlabPipelineAction::Step::PrepareContext,
      GitlabPipelineAction::Step::FetchData,
      GitlabPipelineAction::Step::CloneProject,
      GitlabPipelineAction::Step::PushBranchToGitlab,
      GitlabPipelineAction::Step::TriggerPipeline,
      GitlabPipelineAction::Step::StartRunner,
      GitlabPipelineAction::Step::WaitForPipeline,
      GitlabPipelineAction::Step::StopRunner,
      GitlabPipelineAction::Step::RemoveBranchFromGitlab,
      GitlabPipelineAction::Step::ShowJobLogs
    ].freeze

    def execute(context = Context.new)
      STEPS.each do |step_class|
        step = step_class.new(context)
        print "#{step_class}: "

        if step.skip?
          puts 'skipped'
          next
        end
        puts 'starting'

        start_time = Time.now.to_i
        step.execute
        end_time = Time.now.to_i

        puts "#{step_class}: done (#{end_time - start_time}s)"
      end

      context.gl_pipeline.status == 'success' ? 0 : 1
    end
  end
end

# frozen_string_literal: true

module GitlabPipelineAction
  module Task
    class PipelineAction < Base
      def steps
        [
          GitlabPipelineAction::Step::PrepareContext,
          GitlabPipelineAction::Step::FetchData,
          GitlabPipelineAction::Step::CloneProject,
          GitlabPipelineAction::Step::PushBranchToGitlab,
          GitlabPipelineAction::Step::TriggerPipeline,
          GitlabPipelineAction::Step::StartRunner,
          GitlabPipelineAction::Step::WaitForPipeline,
          GitlabPipelineAction::Step::StopRunner,
          GitlabPipelineAction::Step::RemoveBranchFromGitlab,
          GitlabPipelineAction::Step::ShowJobLogs,
          GitlabPipelineAction::Step::CreateSummary,
          GitlabPipelineAction::Step::CreateOutput
        ].freeze
      end

      def exit_code(context)
        context.gl_pipeline.status == 'success' ? 0 : 1
      end
    end
  end
end

# frozen_string_literal: true

module GitlabPipelineAction
  module Task
    class Runner < Base
      def steps
        [
          GitlabPipelineAction::Step::PrepareContext,
          GitlabPipelineAction::Step::StartRunner,
          GitlabPipelineAction::Step::WaitForPipelinesInProject,
          GitlabPipelineAction::Step::StopRunner
        ].freeze
      end

      def exit_code(_)
        0
      end
    end
  end
end

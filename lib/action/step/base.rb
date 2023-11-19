# frozen_string_literal: true

module GitlabPipelineAction
  module Step
    class Base
      GITLAB_REMOTE = 'gitlab'

      attr_reader :context

      def initialize(context)
        @context = context
      end

      def skip?
        false
      end

      def github
        GitlabPipelineAction::Helper::Github
      end
    end
  end
end

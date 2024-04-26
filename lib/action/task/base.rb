# frozen_string_literal: true

module GitlabPipelineAction
  module Task
    class Base
      def execute(context = Context.new)
        steps.each do |step_class|
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

        exit_code(context)
      end
    end
  end
end

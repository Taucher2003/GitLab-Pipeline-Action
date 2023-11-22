# frozen_string_literal: true

module GitlabPipelineAction
  module Helper
    module Env
      module_function

      def fetch(*args, default: nil, allow_blank: false)
        args.each do |key|
          value = ENV.fetch(key, nil)

          return value if !value.nil? && (!value.strip.empty? || allow_blank)
        end

        default
      end
    end
  end
end

# frozen_string_literal: true

RSpec.configure do
  RSpec::Matchers.define_negated_matcher :not_include, :include
end

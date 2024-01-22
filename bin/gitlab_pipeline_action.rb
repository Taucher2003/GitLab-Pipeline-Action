#!/usr/bin/env ruby
# frozen_string_literal: true

lib = File.expand_path('../lib', __dir__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'gitlab_pipeline_action'

exit GitlabPipelineAction::Task::PipelineAction.new.execute

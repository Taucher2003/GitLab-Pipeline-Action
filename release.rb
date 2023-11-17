#!/usr/bin/env ruby

version = ARGV.shift

action = File.read 'action.yml'
action_for_version = action.gsub("  image: 'Dockerfile'", "  image: 'ghcr.io/taucher2003/gitlab-pipeline-action:#{version}'")
File.write 'action.yml', action_for_version

system("git add action.yml")
system("git commit -m 'Create release for #{version}'")
system("git tag #{version}")

File.write 'action.yml', action
system("git add action.yml")
system("git commit -m 'Reset action to development version'")

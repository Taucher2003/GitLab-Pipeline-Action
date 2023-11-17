#!/usr/bin/env ruby
# frozen_string_literal: true

version = ARGV.shift

readme = File.read 'README.md'
readme_for_version = readme.gsub('Taucher2003/GitLab-Pipeline-Action@<version>',
                                 "Taucher2003/GitLab-Pipeline-Action@#{version}")
File.write 'README.md', readme_for_version

action = File.read 'action.yml'
action_for_version = action.gsub("  image: 'Dockerfile'",
                                 "  image: 'ghcr.io/taucher2003/gitlab-pipeline-action:#{version}'")
File.write 'action.yml', action_for_version

system('git add README.md action.yml')
system("git commit -m 'Create release for #{version}'")
system("git tag #{version}")

File.write 'README.md', readme
File.write 'action.yml', action

system('git add README.md action.yml')
system("git commit -m 'Reset action to development version'")

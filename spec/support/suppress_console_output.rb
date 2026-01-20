# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, :disable_console) do |example|
    original_stdout = $stdout
    original_stderr = $stderr

    example_description = example.metadata[:full_description]
    example_log_path = example_description.gsub(' ', '_').downcase

    tmp_dir = File.expand_path("../../tmp/spec/logs/#{example_log_path}", __dir__)
    FileUtils.mkdir_p tmp_dir

    $stdout = File.open("#{tmp_dir}/stdout", 'w')
    $stderr = File.open("#{tmp_dir}/stderr", 'w')

    example.run

    begin
      $stdout.flush
      $stderr.flush
    ensure
      $stdout.close
      $stderr.close
    end

    $stdout = original_stdout
    $stderr = original_stderr

    if ENV['CI']
      # rubocop:disable RSpec/Output
      GitlabPipelineAction::Helper::Github.with_group "#{example_description} (stdout)" do
        puts File.read "#{tmp_dir}/stdout"
      end
      GitlabPipelineAction::Helper::Github.with_group "#{example_description} (stderr)" do
        puts File.read "#{tmp_dir}/stderr"
      end
      # rubocop:enable RSpec/Output
    end
  end
end

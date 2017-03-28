require "uri"
require "optparse"
require "json"
require "cucumber_booster_config"

module TestBoosters
  require "test_boosters/version"

  require "test_boosters/split_configuration"
  require "test_boosters/cli_parser"
  require "test_boosters/logger"
  require "test_boosters/shell"
  require "test_boosters/leftover_files"
  require "test_boosters/insights_uploader"
  require "test_boosters/project_info"
  require "test_boosters/booster"
  require "test_boosters/job"

  module_function

  def rspec
    split_configuration_path = ENV["RSPEC_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/rspec_split_configuration.json"
    split_configuration = TestBoosters::SplitConfiguration.new(split_configuration_path)

    report_path ||= ENV["REPORT_PATH"] || "#{ENV["HOME"]}/rspec_report.json"

    TestBoosters::Shell.display_title("RSpec Booster v#{TestBoosters::VERSION}")

    TestBoosters::ProjectInfo.display_ruby_version
    TestBoosters::ProjectInfo.display_bundler_version
    TestBoosters::ProjectInfo.display_rspec_version
    TestBoosters::ProjectInfo.display_split_configuration_info(split_configuration)

    options = {
      :command => "bundle exec rspec #{ENV["TB_RSPEC_OPTIONS"]} --format documentation --format json --out #{report_path}",
      :file_pattern => "spec/**/*_spec.rb",
      :split_configuration => split_configuration,
      :job_count => job_count,
      :job_index => job_index
    }

    exit_status = TestBoosters::Booster.run(options)

    TestBoosters::InsightsUploader.upload("rspec", report_path)

    exit_status
  end

  def cucumber
    split_configuration_path = ENV["CUCUMBER_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/cucumber_split_configuration.json"
    split_configuration = TestBoosters::SplitConfiguration.new(split_configuration_path)

    report_path ||= ENV["REPORT_PATH"] || "#{ENV["HOME"]}/cucumber_report.json"

    TestBoosters::Shell.display_title("Cucumber Booster v#{TestBoosters::VERSION}")

    TestBoosters::ProjectInfo.display_ruby_version
    TestBoosters::ProjectInfo.display_bundler_version
    TestBoosters::ProjectInfo.display_cucumber_version
    TestBoosters::ProjectInfo.display_split_configuration_info(split_configuration)

    options = {
      :command => "bundle exec cucumber",
      :file_pattern => "features/**/*.feature",
      :split_configuration => split_configuration,
      :job_count => job_count,
      :job_index => job_index
    }

    CucumberBoosterConfig::Injection.new(Dir.pwd, report_path).run

    exit_status = TestBoosters::Booster.run(options)

    TestBoosters::InsightsUploader.upload("rspec", report_path)

    exit_status
  end

end

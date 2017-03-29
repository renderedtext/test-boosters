module TestBoosters
  module Boosters
    class Cucumber < Base

      FILE_PATTERN = "spec/**/*_spec.rb".freeze

      def initialize
        super(FILE_PATTERN, split_config_path, "bundle exec cucumber")
      end

      def run
        display_title

        CucumberBoosterConfig::Injection.new(Dir.pwd, report_path).run

        exit_status = super

        TestBoosters::InsightsUploader.upload("cucumber", report_path)

        exit_status
      end

      def display_header
        display_title
        TestBoosters::ProjectInfo.display_ruby_version
        TestBoosters::ProjectInfo.display_bundler_version
        TestBoosters::ProjectInfo.display_cucumber_version
      end

      def report_path
        @report_path ||= ENV["REPORT_PATH"] || "#{ENV["HOME"]}/cucumber_report.json"
      end

      def split_configuration_path
        @split_configuration_path ||= ENV["CUCUMBER_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/cucumber_split_configuration.json"
      end

    end
  end
end

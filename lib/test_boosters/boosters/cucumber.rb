module TestBoosters
  module Boosters
    class Cucumber < Base

      FILE_PATTERN = "features/**/*.feature".freeze

      def initialize
        super(FILE_PATTERN, split_configuration_path, command)
      end

      def before_job
        CucumberBoosterConfig::Injection.new(Dir.pwd, report_path).run
      end

      def after_job
        TestBoosters::InsightsUploader.upload("cucumber", report_path)
      end

      def command
        @command ||= "bundle exec cucumber #{cucumber_options}"
      end

      def cucumber_options
        @cucumber_options ||= begin
          "#{ENV["TB_CUCUMBER_OPTIONS"]}"
        end
      end

      def display_header
        super

        TestBoosters::ProjectInfo.display_ruby_version
        TestBoosters::ProjectInfo.display_bundler_version
        TestBoosters::ProjectInfo.display_cucumber_version
      end

      def report_path
        @report_path ||= ENV["REPORT_PATH"] || "#{ENV["HOME"]}/cucumber_report.json"
      end

      def split_configuration_path
        ENV["CUCUMBER_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/cucumber_split_configuration.json"
      end

    end
  end
end



module TestBoosters
  module Cucumber
    class Thread

      attr_reader :files_from_split_configuration
      attr_reader :leftover_files

      def initialize(files_from_split_configuration, leftover_files)
        @files_from_split_configuration = files_from_split_configuration
        @leftover_files = leftover_files
      end

      # :reek:TooManyStatements { max_statements: 10 }
      def run
        if all_files.empty?
          puts("No files to run in this thread!")

          return 0
        end

        run_cucumber_config

        display_thread_info

        exit_status = run_cucumber

        upload_report

        exit_status
      end

      def display_thread_info
        TestBoosters::Shell.display_files(
          "Known specs for this thread",
          files_from_split_configuration)

        TestBoosters::Shell.display_files(
          "Leftover specs for this thread",
          leftover_files)
      end

      def run_cucumber_config
        CucumberBoosterConfig::Injection.new(Dir.pwd, report_path)
        puts "-------------------------------------------------------"
        puts
      end

      def run_cucumber
        TestBoosters::Shell.display_title("Running Cucumber")
        TestBoosters::Shell.execute(cucumber_command)
      end

      def upload_report
        TestBoosters::InsightsUploader.upload("cucumber", report_path)
      end

      def all_files
        @all_files ||= files_from_split_configuration + leftover_files
      end

      def cucumber_command
        "bundle exec cucumber #{all_files.join(" ")}"
      end

      def report_path
        @report_path ||= ENV["REPORT_PATH"] || "#{ENV["HOME"]}/cucumber_report.json"
      end

    end
  end
end

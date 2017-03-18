module TestBoosters
  module Rspec
    class Thread

      attr_reader :files_from_split_configuration
      attr_reader :leftover_files

      def initialize(files_from_split_configuration, leftover_files)
        @files_from_split_configuration = files_from_split_configuration
        @leftover_files = leftover_files
      end

      # :reek:TooManyStatements { max_statements: 10 }
      def run
        TestBoosters::Shell.display_title("RSpec Booster")

        if all_files.empty?
          puts("No files to run in this thread!")

          return 0
        end

        display_thread_info

        exit_status = run_rpsec

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

        puts "RSpec options: #{rspec_options}"
      end

      def run_rspec
        TestBoosters::Shell.display_title("Running RSpec")
        TestBoosters::Shell.execute(rspec_command)
      end

      def upload_report
        TestBoosters::Shell.display_title("Uploading Report")
        TestBoosters::InsightsUploader.upload("rspec", report_path)
      end

      def all_files
        @all_files ||= files_from_split_configuration + leftover_files
      end

      def rspec_options
        "--format documentation --format json --out #{report_path}"
      end

      def rspec_command
        "bundle exec rspec #{rspec_options} #{all_files.join(" ")}"
      end

      def report_path
        @report_path ||= ENV["REPORT_PATH"] || "#{ENV["HOME"]}/rspec_report.json"
      end

    end
  end
end

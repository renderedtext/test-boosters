module TestBoosters
  module Boosters
    class Base

      def initialize(file_pattern, exclude_pattern, split_configuration_path, command)
        @command = command
        @file_pattern = file_pattern
        @exclude_pattern = exclude_pattern
        @split_configuration_path = split_configuration_path
      end

      # :reek:TooManyStatements
      def run
        display_header

        before_job # execute some activities when the before the job starts

        distribution.display_info

        known, leftover = distribution.files_for(job_index)

        if cli_options[:dry_run]
          show_files_for_dry_run("known", known)
          show_files_for_dry_run("leftover", leftover)
          return 0
        end

        exit_status = TestBoosters::Job.run(@command, known, leftover)

        after_job # execute some activities when the job finishes

        exit_status
      end

      def show_files_for_dry_run(label, files)
        if files.empty?
          puts "[DRY RUN] No #{label} files."
          return
        end

        puts "\n[DRY RUN] Running tests for #{label} files:"
        puts files.map { |file| "- #{file}" }.join("\n")
      end

      def before_job
        # Do nothing
      end

      def after_job
        # Do nothing
      end

      def display_header
        version = "Test Booster v#{TestBoosters::VERSION}"
        job_info = "Job #{job_index + 1} out of #{job_count}"

        TestBoosters::Shell.display_title("#{version} - #{job_info}")
      end

      def distribution
        @distribution ||= TestBoosters::Files::Distributor.new(@split_configuration_path,
                                                               @file_pattern,
                                                               @exclude_pattern,
                                                               job_count)
      end

      def job_index
        @job_index ||= cli_options[:job_index] - 1
      end

      def job_count
        @job_count ||= cli_options[:job_count]
      end

      private

      def cli_options
        @cli_options ||= TestBoosters::CliParser.parse
      end

    end
  end
end

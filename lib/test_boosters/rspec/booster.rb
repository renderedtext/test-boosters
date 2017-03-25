module TestBoosters
  module Rspec
    class Booster

      attr_reader :job_index
      attr_reader :job_count

      def initialize(job_index, job_count)
        @job_index = job_index
        @job_count = job_count
      end

      def run
        TestBoosters::Shell.display_title("RSpec Booster v#{TestBoosters::VERSION}")
        display_system_info

        jobs[@job_index].run
      end

      def display_system_info
        TestBoosters::ProjectInfo.display_ruby_version
        TestBoosters::ProjectInfo.display_bundler_version
        TestBoosters::ProjectInfo.display_rspec_version
        TestBoosters::ProjectInfo.display_split_configuration_info(split_configuration)
        puts
      end

      def jobs
        @jobs ||= Array.new(job_count) do |job_index|
          known    = all_specs & split_configuration.files_for_job(job_index)
          leftover = leftover_specs.select(:index => job_index, :total => job_count)

          TestBoosters::Rspec::Job.new(known, leftover)
        end
      end

      def all_specs
        @all_specs ||= Dir["#{specs_path}/**/*_spec.rb"].sort
      end

      def leftover_specs
        @leftover_specs ||= TestBoosters::LeftoverFiles.new(all_specs - split_configuration.all_files)
      end

      def split_configuration
        @split_configuration ||= TestBoosters::SplitConfiguration.new(split_configuration_path)
      end

      def specs_path
        @specs_path ||= ENV["SPEC_PATH"] || "spec"
      end

      def split_configuration_path
        ENV["RSPEC_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/rspec_split_configuration.json"
      end

    end
  end
end

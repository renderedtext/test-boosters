module TestBoosters
  module Rspec
    class Booster

      attr_reader :thread_index
      attr_reader :thread_count

      def initialize(thread_index, thread_count)
        @thread_index = thread_index
        @thread_count = thread_count
      end

      def run
        display_system_info

        unless split_configuration.valid?
          puts "[ERROR] The split configuration file is malformed!"

          return 1 # failure exit status
        end

        threads[@thread_index].run
      end

      def display_system_info
        TestBoosters::Shell.display_title("RSpec Booster v#{TestBoosters::VERSION}")

        TestBoosters::ProjectInfo.display_ruby_version
        TestBoosters::ProjectInfo.display_bundler_version
        TestBoosters::ProjectInfo.display_rspec_version

        puts
      end

      def threads
        @threads ||= Array.new(@thread_count) do |thread_index|
          known_files = all_specs & split_configuration.files_for_thread(thread_index)
          leftover_files = TestBoosters::LeftoverFiles.select(all_leftover_specs, thread_count, thread_index)

          TestBoosters::Rspec::Thread.new(known_files, leftover_files)
        end
      end

      def all_specs
        @all_specs ||= Dir["#{specs_path}/**/*_spec.rb"].sort
      end

      def all_leftover_specs
        @all_leftover_specs ||= all_specs - split_configuration.all_files
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

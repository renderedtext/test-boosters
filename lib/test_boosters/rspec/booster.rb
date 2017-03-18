module TestBoosters
  module Rspec
    class Booster

      def initialize(thread_index)
        @thread_index = thread_index
      end

      def run
        threads[@thread_index].run
      end

      def thread_count
        @thread_count ||= split_configuration.thread_count
      end

      def threads
        @threads ||= Array.new(thread_index) do |thread_index|
          known_files = all_specs & split_configuration.files_for_thread(thread_index)
          leftover_files = TestBoosters::LeftoverFiles.select(all_leftover_specs, threads_count, thread_index)

          TestBoosters::Rspec::Thread.new(known_files, leftover_files)
        end
      end

      def all_specs
        @all_specs ||= Dir["#{specs_path}/**/*_spec.rb"].sort
      end

      def all_leftover_specs
        @all_leftover_specs ||= all_specs - split_configuration.all_files
      end

      def specs_path
        @specs_path ||= ENV["SPEC_PATH"] || "spec"
      end

      def split_configuration
        @split_configuration ||= TestBoosters::SplitConfiguration.new(split_configuration_path)
      end

      def split_configuration_path
        ENV["RSPEC_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/rspec_split_configuration.json"
      end

    end
  end
end

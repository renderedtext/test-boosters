module TestBoosters
  module Cucumber
    class Booster

      def initialize(thread_index)
        @thread_index = thread_index
      end

      def run
        TestBoosters::Shell.display_title("Cucumber Boster v#{TestBoosters::VERSION}")

        unless split_configuration.valid?
          puts "[ERROR] The split configuration file is malformed!"

          return 1 # failure exit status
        end

        threads[@thread_index].run
      end

      def thread_count
        @thread_count ||= split_configuration.thread_count
      end

      def threads
        @threads ||= Array.new(thread_count) do |thread_index|
          known_files = all_specs & split_configuration.files_for_thread(thread_index)
          leftover_files = TestBoosters::LeftoverFiles.select(all_leftover_specs, thread_count, thread_index)

          TestBoosters::Cucumber::Thread.new(known_files, leftover_files)
        end
      end

      def all_specs
        @all_specs ||= Dir["#{specs_path}/**/*.feature"].sort
      end

      def all_leftover_specs
        @all_leftover_specs ||= all_specs - split_configuration.all_files
      end

      def split_configuration
        @split_configuration ||= TestBoosters::SplitConfiguration.new(split_configuration_path)
      end

      def specs_path
        @specs_path ||= ENV["SPEC_PATH"] || "features"
      end

      def split_configuration_path
        ENV["CUCUMBER_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/cucumber_split_configuration.json"
      end

    end
  end
end

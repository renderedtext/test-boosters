module TestBoosters
  module Rspec
    class Specs

      def initialize(thread_index)
        @thread_index = thread_index
      end

      def for_thread
        @for_thread ||= thread_specs + thread_leftover_specs
      end

      def known_specs_for_current_thread
        @known_specs_for_current_thread ||= all_specs & split_configuration.files_for_thread(@thread_index)
      end

      def leftover_specs_for_current_thread
        @leftover_specs_for_current_thread ||= TestBoosters::LeftoverFiles.select(
          all_leftover_specs,
          split_configuration.threads.count,
          @thread_index)
      end

      def all_specs
        @all_specs ||= Dir["#{specs_path}/**/*_spec.rb"].sort
      end

      def all_known_specs
        @all_known_specs ||= @split_configuration.all_files
      end

      def all_leftover_specs
        @all_leftover_specs ||= all_specs - all_known_specs
      end

      def specs_path
        @specs_path = ENV["SPEC_PATH"] || "spec"
      end

      def split_configuration
        @split_configuration ||= TestBoosters::SplitConfiguration.for_rspec
      end

    end
  end
end

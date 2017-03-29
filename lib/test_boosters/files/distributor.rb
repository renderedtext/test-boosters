module TestBoosters
  module Files

    #
    # Distributes test files based on split configuration, file pattern, and their file size
    #
    class Distributor

      def initialize(split_configuration_path, file_pattern, job_count)
        @split_configuration_path = split_configuration_path
        @file_pattern = file_pattern
        @job_count = job_count
      end

      def display_info
        puts "Split configuration present: #{split_configuration.present? ? "yes" : "no"}"
        puts "Split configuration valid: #{split_configuration.valid? ? "yes" : "no"}"
        puts "Split configuration file count: #{split_configuration.all_files.size}"
      end

      def files_for(job_index)
        known    = all_files & split_configuration.files_for_job(job_index)
        leftover = leftover_files.select(:index => job_index, :total => @job_count)

        [known, leftover]
      end

      def all_files
        @all_files ||= Dir[@file_pattern].sort
      end

      private

      def leftover_files
        @leftover_files ||= TestBoosters::Files::LeftoverFiles.new(all_files - split_configuration.all_files)
      end

      def split_configuration
        @split_configuration ||= TestBoosters::Files::SplitConfiguration.new(@split_configuration_path)
      end

    end

  end
end

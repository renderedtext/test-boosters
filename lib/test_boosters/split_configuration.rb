module TestBoosters
  class SplitConfiguration

    class Thread < Struct.new(:files, :thread_index)
    end

    def self.for_rspec
      path = ENV["RSPEC_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/rspec_split_configuration.json"

      new(path)
    end

    def initialize(path)
      @path = path
    end

    def present?
      File.exist?(@path)
    end

    def all_files
      @all_files ||= threads.map(&:files).flatten.sort
    end

    def files_for_thread(thread_index)
      threads[thread_index].files
    end

    def threads
      @thread ||= load_data.map.with_index do |raw_thread, index|
        TestBoosters::SplitConfiguration::Thread.new(raw_thread["files"].sort, index)
      end
    end

    private

    def load_data
      if present?
        JSON.parse(File.read(@path))
      else
        []
      end
    end

  end
end

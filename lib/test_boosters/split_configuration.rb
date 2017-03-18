module TestBoosters
  class SplitConfiguration

    Thread = Struct.new(:files, :thread_index)

    def self.for_rspec
      path_from_env = ENV["RSPEC_SPLIT_CONFIGURATION_PATH"]
      default_path = "#{ENV["HOME"]}/rspec_split_configuration.json"

      new(path_from_env || default_path)
    end

    def self.for_cucumber
      path_from_env = ENV["CUCUMBER_SPLIT_CONFIGURATION_PATH"]
      default_path = "#{ENV["HOME"]}/cucumber_split_configuration.json"

      new(path_from_env || default_path)
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
      @threads ||= load_data.map.with_index do |raw_thread, index|
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

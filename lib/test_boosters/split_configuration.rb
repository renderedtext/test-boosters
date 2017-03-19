module TestBoosters
  class SplitConfiguration

    Thread = Struct.new(:files, :thread_index)

    def initialize(path)
      @path = path
    end

    def present?
      File.exist?(@path)
    end

    def valid?
      threads # try to load data into memory
      true
    rescue
      false
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

    def thread_count
      @thread_count ||= threads.count
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

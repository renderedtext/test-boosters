module TestBoosters
  class SplitConfiguration

    Thread = Struct.new(:files, :thread_index)

    def initialize(path)
      @path = path
      @valid = true
    end

    def present?
      File.exist?(@path)
    end

    def valid?
      threads # try to load data into memory

      @valid
    end

    def all_files
      @all_files ||= threads.map(&:files).flatten.sort
    end

    def files_for_thread(thread_index)
      thread = threads[thread_index]

      thread ? thread.files : []
    end

    def threads
      @threads ||= present? ? load_data : []
    end

    private

    # :reek:TooManyStatements
    def load_data
      JSON.parse(File.read(@path)).map.with_index do |raw_thread, index|
        TestBoosters::SplitConfiguration::Thread.new(raw_thread.fetch("files").sort, index)
      end
    rescue StandardError => ex
      @valid = false

      TestBoosters::Logger.error(ex.inspect)

      []
    end

  end
end

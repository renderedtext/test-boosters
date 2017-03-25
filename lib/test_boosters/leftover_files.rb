module TestBoosters
  class LeftoverFiles

    attr_reader :files

    def initialize(files)
      @files = files
    end

    def select(options = {})
      index = options.fetch(:index)
      total = options.fetch(:total)

      file_distribution(total)[index]
    end

    private

    def file_distribution(thread_count)
      # create N empty boxes
      threads = Array.new(thread_count) { [] }

      # distribute files in Round Robin fashion
      sorted_files_by_file_size.each.with_index do |file, index|
        threads[index % thread_count] << file
      end

      threads
    end

    def sorted_files_by_file_size
      @sorted_files_by_file_size ||= existing_files.sort_by { |file| -File.size(file) }
    end

    def existing_files
      @existing_files ||= @files.select { |file| File.file?(file) }
    end

  end
end

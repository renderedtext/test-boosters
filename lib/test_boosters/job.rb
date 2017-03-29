module TestBoosters
  class Job

    def initialize(command, known_files, leftover_files)
      @command = command
      @known_files = known_files
      @leftover_files = leftover_files
    end

    def display_header
      TestBoosters::Shell.display_files("Known files for this job", @known_files)
      TestBoosters::Shell.display_files("Leftover files for this job", @leftover_files)
    end

    def files
      @all_files ||= @known_files + @leftover_files
    end

    def run
      display_header

      if files.empty?
        puts("No files to run in this job!")

        return 0
      end

      TestBoosters::Shell.execute("#{@command} #{files.join(" ")}")
    end

  end
end

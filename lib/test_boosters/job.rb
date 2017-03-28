module TestBoosters
  class Job

    attr_reader :files_from_split_configuration
    attr_reader :leftover_files
    attr_reader :command

    def initialize(command, files_from_split_configuration, leftover_files)
      @command = command
      @files_from_split_configuration = files_from_split_configuration
      @leftover_files = leftover_files
    end

    # :reek:TooManyStatements { max_statements: 10 }
    def run
      if all_files.empty?
        puts("No files to run in this job!")

        return 0
      end

      display_job_info
      run_rspec
    end

    def display_job_info
      TestBoosters::Shell.display_files("Known files for this job", files_from_split_configuration)
      TestBoosters::Shell.display_files("Leftover files for this job", leftover_files)
    end

    def run_rspec
      TestBoosters::Shell.display_title("Running RSpec")
      TestBoosters::Shell.execute("#{@command} #{all_files.join(" ")}")
    end

    def all_files
      @all_files ||= files_from_split_configuration + leftover_files
    end

  end
end

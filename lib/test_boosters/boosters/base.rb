module TestBoosters::Boosters
  class Base

    def initialize(file_pattern, split_configuration_path, command)
      @command = command
      @file_pattern = file_pattern
      @split_configuration_path = split_configuration_path
    end

    def display_title
      TestBoosters::Shell.display_title("Booster v#{TestBoosters::VERSION} - Job #{job_index + 1} out of #{job_count}")
    end

    def run
      known, leftover = distribution.files_for(job_index)

      TestBoosters::Job.new(command, known, leftover).run
    end

    def distribution
      @distribution ||= TestBoosters::Files::Distributor.new(@split_configuration_path, @file_pattern, job_count)
    end

    def job_index
      @job_index ||= cli_options[:job_index] - 1
    end

    def job_count
      @job_count ||= cli_options[:job_count]
    end

    private


    def cli_options
      @cli_options ||= TestBoosters::CliParser.parse
    end

  end
end

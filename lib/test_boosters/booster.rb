module TestBoosters
  class Booster

    def initialize(options = {})
      @command = options.featch(:command)
      @file_pattern = options.featch(:file_pattern)
      @split_configuration = options.featch(:split_configuration)
      @job_count = options.featch(:job_count)
      @job_index = options.featch(:job_index)
    end

    def run
      jobs[@job_index].run
    end

    def jobs
      @jobs ||= Array.new(job_count) do |job_index|
        known    = all_specs & split_configuration.files_for_job(job_index)
        leftover = leftover_specs.select(:index => job_index, :total => job_count)

        TestBoosters::Job.new(@command, known, leftover)
      end
    end

    def all_specs
      @all_specs ||= Dir[@file_pattern].sort
    end

    def leftover_specs
      @leftover_specs ||= TestBoosters::LeftoverFiles.new(all_specs - @split_configuration.all_files)
    end

  end
end

module TestBoosters
  class Booster

    def self.run(options = {})
      new(options).run
    end

    def initialize(options = {})
      @command = options.fetch(:command)
      @file_pattern = options.fetch(:file_pattern)
      @split_configuration = options.fetch(:split_configuration)
      @job_count = options.fetch(:job_count)
      @job_index = options.fetch(:job_index)
    end

    def run
      jobs[@job_index].run
    end

    def jobs
      @jobs ||= Array.new(@job_count) do |job_index|
        known    = all_specs & @split_configuration.files_for_job(job_index)
        leftover = leftover_specs.select(:index => job_index, :total => @job_count)

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

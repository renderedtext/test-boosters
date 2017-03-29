module TestBoosters
  module Files
    class SplitConfiguration

      Job = Struct.new(:files)

      def initialize(path)
        @path = path
        @valid = true
      end

      def present?
        File.exist?(@path)
      end

      def valid?
        jobs # try to load data into memory

        @valid
      end

      def all_files
        @all_files ||= jobs.map(&:files).flatten.sort
      end

      def files_for_job(job_index)
        job = jobs[job_index]

        job ? job.files : []
      end

      def jobs
        @jobs ||= present? ? load_data : []
      end

      private

      # :reek:TooManyStatements
      def load_data
        @valid = false

        content = JSON.parse(File.read(@path)).map do |raw_job|
          files = raw_job.fetch("files").sort

          TestBoosters::Files::SplitConfiguration::Job.new(files)
        end

        @valid = true

        content
      rescue TypeError, KeyError => ex
        log_error("Split Configuration has invalid structure", ex)

        []
      rescue JSON::ParserError => ex
        log_error("Split Configuration is not parsable", ex)

        []
      end

      def log_error(message, exception)
        TestBoosters::Logger.error(message)
        TestBoosters::Logger.error(exception.inspect)
      end

    end
  end
end

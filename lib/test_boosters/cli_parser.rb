module TestBoosters
  module CliParser
    module_function

    # :reek:TooManyStatements
    # :reek:NestedIterators
    # :reek:DuplicateMethodCall
    def parse
      options = {}

      parser = OptionParser.new do |opts|
        opts.on(
          "--thread INDEX",
          "[DEPRECATED] Use the '--job' option instead"
        ) do |parameter|
          puts "[DEPRECATION WARNING] The '--thread' parameter is deprecated. Please use '--job' instead."

          options.merge!(parse_job_params(parameter))
        end

        opts.on(
          "--job INDEX",
          "The job index and number of total jobs. e.g. --job 4/32"
        ) do |parameter|
          options.merge!(parse_job_params(parameter))
        end

        opts.on(
          "--dry-run",
          "Only print the files that will be run for this job index"
        ) do |parameter|
          options.merge!(:dry_run => parameter)
        end
      end

      parser.parse!

      options
    end

    # parses input like '1/32' and outputs { :job_index => 1, :job_count => 32 }
    def parse_job_params(input_parameter)
      job_index, job_count, _rest = input_parameter.split("/")

      { :job_index => job_index.to_i, :job_count => job_count.to_i }
    end

  end
end

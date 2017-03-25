module TestBoosters
  module CliParser
    module_function

    # :reek:TooManyStatements
    # :reek:NestedIterators
    # :reek:DuplicateMethodCall
    def parse
      options = {}

      parser = OptionParser.new do |opts|
        opts.on("--thread INDEX") do |parameter|
          puts "[DEPRECATION WARNING] The '--thread' parameter is deprecated. Please use '--job' instead."

          job_index, job_count, _rest = parameter.split("/")

          options[:job_index] = job_index.to_i
          options[:job_count] = job_count.to_i
        end

        opts.on("--job INDEX") do |parameter|
          job_index, job_count, _rest = parameter.split("/")

          options[:job_index] = job_index.to_i
          options[:job_count] = job_count.to_i
        end
      end

      parser.parse!

      options
    end
  end
end

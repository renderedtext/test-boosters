module TestBoosters
  module CliParser
    module_function

    # :reek:TooManyStatements
    def parse
      options = {}

      parser = OptionParser.new do |opts|
        opts.on("--thread INDEX") do |parameter|
          thread_index, thread_count, _rest = parameter.split("/")

          options[:thread_index] = thread_index.to_i
          options[:thread_count] = thread_count.to_i
        end
      end

      parser.parse!

      options
    end
  end
end

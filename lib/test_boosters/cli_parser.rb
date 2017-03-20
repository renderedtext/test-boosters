module TestBoosters
  module CliParser
    module_function

    def parse
      options = {}

      parser = OptionParser.new do |opts|
        opts.on("--thread INDEX") do |parameter|
          options[:thread_index] = parameter.split("/")[0].to_i
          options[:thread_count] = parameter.split("/")[1].to_i
        end
      end

      parser.parse!

      options
    end
  end
end

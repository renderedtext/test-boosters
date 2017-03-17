module TestBoosters
  module CliParser
    module_function

    def parse
      options = {}

      parser = OptionParser.new do |opts|
        opts.on("--thread INDEX") { |index| options[:index] = index.to_i }
      end

      parser.parse!

      options
    end
  end
end

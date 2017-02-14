require "optparse"

def parse
  options = {}

  parser = OptionParser.new do |opts|
    opts.on("--thread INDEX") { |index| options[:index] = index.to_i }
  end

  parser.parse!

  options
end

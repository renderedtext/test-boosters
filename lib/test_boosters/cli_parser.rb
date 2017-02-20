module Semaphore
  require "optparse"

  def self.parse
    options = {}

    parser = OptionParser.new do |opts|
      opts.on("--thread INDEX") { |index| options[:index] = index.to_i }
    end

    parser.parse!

    options
  end
end

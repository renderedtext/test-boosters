module TestBoosters
  module Boosters
    class Minitest < Base

      FILE_PATTERN = "test/**/*_test.rb".freeze

      def initialize
        super(FILE_PATTERN, nil, split_configuration_path, command)
      end

      def command
        "ruby -e 'ARGV.each { |f| require \"./\#{f}\" }'"
      end

      def split_configuration_path
        ENV["MINITEST_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/minitest_split_configuration.json"
      end

    end
  end
end

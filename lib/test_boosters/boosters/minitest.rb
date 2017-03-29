module TestBoosters
  module Boosters
    class Minitest < Base

      FILE_PATTERN = "test/**/*/_test.rb".freeze

      def initialize
        super(FILE_PATTERN, split_configuration_path, "ruby")
      end

      def split_configuration_path
        ENV["MINITEST_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/minitest_split_configuration.json"
      end

    end
  end
end

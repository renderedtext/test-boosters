module TestBoosters
  module Boosters
    class GoTest < Base

      FILE_PATTERN = "**/*/*_test.go".freeze

      def initialize
        super(FILE_PATTERN, nil, split_configuration_path, "go test")
      end

      def split_configuration_path
        ENV["GO_TEST_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/go_test_split_configuration.json"
      end

    end
  end
end

module TestBoosters
  module Boosters
    class ExUnit < Base

      FILE_PATTERN = "test/**/*_test.exs".freeze

      def initialize
        super(FILE_PATTERN, nil, split_configuration_path, "mix test")
      end

      def split_configuration_path
        ENV["EX_UNIT_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/ex_unit_split_configuration.json"
      end

    end
  end
end

module TestBoosters
  module Boosters
    class Minitest < Base

      FILE_PATTERN = "test/**/*_test.rb".freeze

      def initialize
        super(FILE_PATTERN, nil, split_configuration_path, command)
      end

      def command
        if command_set_with_env_var?
          command_from_env_var
        elsif rails_app?
          "bundle exec rails test"
        else
          "ruby -e 'ARGV.each { |f| require \"./\#{f}\" }'"
        end
      end

      def split_configuration_path
        ENV["MINITEST_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/minitest_split_configuration.json"
      end

      def command_set_with_env_var?
        !command_from_env_var.empty?
      end

      def command_from_env_var
        ENV["MINITEST_BOOSTER_COMMAND"].to_s
      end

      private

      def rails_app?
        File.exist?("app") && File.exist?("config") && File.exist?("config/application.rb")
      end

    end
  end
end

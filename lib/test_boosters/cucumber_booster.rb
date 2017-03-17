module TestBoosters
  require "json"
  require "test_boosters/cli_parser"
  require "test_boosters/logger"
  require "test_boosters/executor"
  require "test_boosters/display_files"
  require "test_boosters/leftover_files"

  class CucumberBooster
    attr_reader :report_path

    def initialize(thread_index)
      @thread_index = thread_index
      @cucumber_split_configuration_path = ENV["CUCUMBER_SPLIT_CONFIGURATION_PATH"] || "#{ENV["HOME"]}/cucumber_split_configuration.json"
      @report_path = "#{ENV["HOME"]}/rspec_report.json"
      @spec_path = ENV["SPEC_PATH"] || "features"
    end

    def run
      exit_code = true
      begin
        features_to_run = select

        if features_to_run.empty?
          puts "No feature files in this thread!"
        else
          exit_code = run_command(features_to_run.join(" "))
        end
      rescue StandardError => e
        if @thread_index == 0
          exit_code = run_command(@spec_path)
        end
      end
      exit_code
    end

    def run_command(specs)
      puts
      puts "========================= Running Cucumber =========================="
      puts

      TestBoosters.execute("bundle exec cucumber #{specs}")
    end

    def select
      with_fallback do
        file_distribution = JSON.parse(File.read(@cucumber_split_configuration_path))
        thread_count = file_distribution.count
        thread = file_distribution[@thread_index]

        all_features = Dir["#{@spec_path}/**/*.feature"].sort
        all_known_features = file_distribution.map { |t| t["files"] }.flatten.sort

        all_leftover_features = all_features - all_known_features
        thread_leftover_features = TestBoosters::LeftoverFiles.select(all_leftover_features, thread_count, @thread_index)
        thread_features = all_features & thread["files"].sort
        features_to_run = thread_features + thread_leftover_features

        TestBoosters::Shell.display_files("This thread features:", thread_features)
        TestBoosters::Shell.display_title_and_count("All leftover features:", all_leftover_features)
        TestBoosters::Shell.display_files("This thread leftover features:", thread_leftover_features)

        features_to_run
      end
    end

    def with_fallback
      yield
    rescue StandardError => e
      error = %{
        WARNING: An error detected while parsing the test boosters report file.
        WARNING: All tests will be executed on the first thread.
      }

      puts error

      error += %{Exception: #{e.message}}

      TestBoosters.log(error)

      raise
    end
  end
end

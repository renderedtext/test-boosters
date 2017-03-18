require "optparse"
require "json"
require "cucumber_booster_config"

module TestBoosters
  require "test_boosters/version"

  require "test_boosters/split_configuration"
  require "test_boosters/cli_parser"
  require "test_boosters/logger"
  require "test_boosters/shell"
  require "test_boosters/leftover_files"

  require "test_boosters/rspec/booster"
  require "test_boosters/cucumber_booster"
  require "test_boosters/insights_uploader"

  module_function

  def run_cucumber_config
    puts
    puts "================== Running Cucumber Booster Config ==================="
    puts

    CucumberBoosterConfig::CLI.start ["inject", "."]
  end
end

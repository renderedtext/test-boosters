require 'cucumber_booster_config'

module TestBoosters
  module_function

  def run_cucumber_config()
    puts
    puts "================== Running Cucumber Booster Config ==================="
    puts

    CucumberBoosterConfig::CLI.start ["inject", "."]
  end
end

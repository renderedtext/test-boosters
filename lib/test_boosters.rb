require "uri"
require "optparse"
require "json"
require "cucumber_booster_config"

module TestBoosters
  require "test_boosters/version"

  require "test_boosters/cli_parser"
  require "test_boosters/logger"
  require "test_boosters/shell"
  require "test_boosters/insights_uploader"
  require "test_boosters/project_info"
  require "test_boosters/job"

  require "test_boosters/files/distributor"
  require "test_boosters/files/leftover_files"
  require "test_boosters/files/split_configuration"

  require "test_boosters/boosters/base"
  require "test_boosters/boosters/rspec"
  require "test_boosters/boosters/cucumber"
  require "test_boosters/boosters/go_test"
  require "test_boosters/boosters/ex_unit"
  require "test_boosters/boosters/minitest"

  ROOT_PATH = File.absolute_path(File.dirname(__FILE__) + "/..")
end

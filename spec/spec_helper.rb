require "simplecov"
SimpleCov.start { add_filter "/spec/" }

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "test_boosters"
require "securerandom"

require_relative "support/coverage"
require_relative "support/rspec_files_factory"
require_relative "support/cucumber_files_factory"
require_relative "support/split_configuration_factory"

RSpec.configure do |config|

  # test coverage percentage only if the whole suite was executed
  unless config.files_to_run.one?
    config.after(:suite) do
      example_group = RSpec.describe("Code coverage")

      example_group.example("must be 100%") do
        coverage = SimpleCov.result
        percentage = coverage.covered_percent

        Support::Coverage.display(coverage)

        expect(percentage).to eq(100)
      end

      # quickfix to resolve weird behaviour in rspec
      raise "coverage is too low" unless example_group.run(RSpec.configuration.reporter)
    end
  end

end

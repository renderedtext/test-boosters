require "simplecov"

SimpleCov.start do
  add_filter "spec/"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "test_boosters"
require_relative "support/coverage"
require_relative "support/rspec_files_factory"

MINIMAL_COVERAGE_PERCENTAGE = 84

RSpec.configure do |config|

  # test coverage only if the whole suite was executed
  unless config.files_to_run.one?
    config.after(:suite) do
      example_group = RSpec.describe("Code coverage")

      example_group.example("must be above #{MINIMAL_COVERAGE_PERCENTAGE}%") do
        coverage = SimpleCov.result
        percentage = coverage.covered_percent

        Support::Coverage.display(coverage)

        expect(percentage).to be > MINIMAL_COVERAGE_PERCENTAGE
      end

      example_group.run(RSpec.configuration.reporter)
    end
  end

end

module Setup
  module_function

  def spec_dir
    "test_data"
  end

  def a
    "test_data/a_spec.rb"
  end

  def b
    "test_data/b_spec.rb"
  end

  def c
    "test_data/c_spec.rb"
  end

  def input_specs
    [a, b, c]
  end

  def expected_specs
    [a, c, b]
  end

  module Cucumber
    module_function

    def feature_dir
      "test_data"
    end

    def a
      "test_data/a.feature"
    end

    def b
      "test_data/b.feature"
    end

    def c
      "test_data/c.feature"
    end

    def input_specs
      [a, b, c]
    end

    def expected_specs
      [a, c, b]
    end

  end
end

require "simplecov"

SimpleCov.start do
  add_filter "spec/"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "test_boosters"
require_relative "support/coverage"

RSpec.configure do |config|

  config.after(:suite) do
    example_group = RSpec.describe('Code coverage')

    example_group.example("must be above 84%") do
      coverage = SimpleCov.result
      percentage = coverage.covered_percent

      Support::Coverage.display(coverage)

      expect(percentage).to be > 84
    end

    example_group.run(RSpec.configuration.reporter)
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

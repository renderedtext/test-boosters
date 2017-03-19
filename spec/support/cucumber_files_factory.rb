require "securerandom"

module Support
  module CucubmerFilesFactory
    module_function

    def create(options = {})
      path   = options[:path]
      name   = options[:name] || "RandomTest"
      result = options[:result] || :passing

      FileUtils.mkdir_p(File.dirname(path))

      File.write(path, create_feature_content(name))
      File.write("feature/step_definitions/#{name}_step.rb", create_step_content(name))
    end

    def create_feature_content(name)
      <<-FEATURE_FILE
      Feature: #{name}

        As a user
        I want to be able to manage #{name}

        Scenario: Testing out #{name}
          When I open #{name} path
          Then I should see #{name}
      FEATURE_FILE
    end

    def create_step_definition(name, result)
      <<-STEP_FILE
      When(/^I open #{name} path/) do
        puts "Opening #{name}"
      end

      Then(/^I should see #{name}$/) do
        expect(1 + 1).to eq(#{result == :passing ? 2 : 42})
      end
      STEP_FILE
    end

  end
end

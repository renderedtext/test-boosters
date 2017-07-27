RSpec::Support.require_rspec_core "formatters/base_formatter"
require 'json'

class SemaphoreFormatter < RSpec::Core::Formatters::BaseFormatter
  RSpec::Core::Formatters.register self, :stop, :close

  attr_reader :output_hash

  def initialize(output)
    super
    @output_hash = {}
  end

  def stop(notification)
    @output_hash[:examples] = notification.examples.map { |example| format_example(example) }
  end

  def close(_notification)
    output.write @output_hash.to_json
    output.close if IO === output && output != $stdout
  end

  private

  def format_example(example)
    result = example.execution_result

    {
      :description => example.description,
      :full_description => example.full_description,
      :status => result.status,
      :file_path => file_path(example),
      :run_time => result.run_time
    }
  end

  def file_path(example)
    # For shared examples 'example.file_path' returns the path of the shared example file.
    # This is not optinal for our use case because we can't estimate the duration of the
    # original spec file.
    #
    # To resolve this, we use `example.metadata[:example_group]` that contains the correct
    # file path for both shared examples and regular tests

    find_example_group_root_path(example.metadata[:example_group])
  end

  def find_example_group_root_path(example_group)
    if example_group.has_key?(:parent_example_group)
      find_example_group_root_path(example_group[:parent_example_group])
    else
      example_group[:file_path]
    end
  end
end

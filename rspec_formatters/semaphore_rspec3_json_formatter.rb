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
    # In case of a shared_example
    # example[:file_path] returns the path of the shared_example file
    #
    # We are interested in the duration of the file from which the shared_example was called instead.
    #
    # We can get this infor from `example.id`.
    #
    # It has the following format: `./spec/models/analysis_spec.rb[1:17:1:1:1]`
    # We are droping the angle brackets at the end.

    example.id.gsub(/\[.*\]$/, "")
  end
end

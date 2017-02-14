#!/usr/bin/env ruby

require "optparse"
require "json"

def log(message)
  error_log_path = ENV["ERROR_LOG_PATH"] || "#{ENV["HOME"]}/test_booster_error.log"

  File.open(error_log_path, "a") { |f| f.write("#{message}\n") }
end

def display_files(title, files)
  puts "#{title} #{files.count}\n"

  files.each { |file| puts "- #{file}" }

  puts "\n"
end

def execute(command)
  log("Running command: #{command}")
  system(command)
  log("Command finished, exit status : #{$?.exitstatus}")

  exit($?.exitstatus)
end

def parse_cli_options
  options = {}

  parser = OptionParser.new do |opts|
    opts.on("--thread INDEX") { |index| options[:index] = index.to_i }
  end

  parser.parse!

  options
end

def with_fallback
  yield
rescue StandardError => e
  error = %{
WARNING: An error detected while parsing the test boosters report file.
WARNING: All tests will be executed on the first thread.
}

  puts error

  error += %{
Exception:
#{e.message}
}

  log(error)

  execute("bundle exec rspec") if $cli_options[:index] == 1
end

$cli_options = parse_cli_options

report_path = ENV["REPORT_PATH"] || "#{ENV["HOME"]}/rspec_report.json"
spec_path = ENV["SPEC_PATH"] || "spec"

with_fallback do
  rspec_report = JSON.parse(File.read(report_path))

  thread = rspec_report[$cli_options[:index] - 1]

  all_specs = Dir["#{spec_path}/**/*_spec.rb"].sort
  all_known_specs = rspec_report.map { |t| t["files"] }.flatten.sort

  leftover_specs = all_specs - all_known_specs
  thread_specs = all_specs & thread["files"].sort
  specs_to_run = thread_specs + (thread["run_leftover_files"] ? leftover_specs : [])

  display_files("Thread specs:", thread_specs)

  display_files("Leftover specs:", leftover_specs) if thread["run_leftover_files"]

  if specs_to_run.empty?
    puts "No spec files in this thread!"
    exit
  end

  execute("bundle exec rspec #{specs_to_run.join(" ")}")
end

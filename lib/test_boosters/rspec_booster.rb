require "json"


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


def with_fallback
  yield
rescue StandardError => e
  error = %{
    WARNING: An error detected while parsing the test boosters report file.
    WARNING: All tests will be executed on the first thread.
  }

  puts error

  error += %{Exception: #{e.message}}

  log(error)

  "error"
end

def select_leftover_specs(all_leftover_specs, thread_count, thread_index)
  all_leftover_specs = sort_by_size(all_leftover_specs)

  return [] if all_leftover_specs.empty?

  specs = all_leftover_specs
    .each_slice(thread_count)
    .reduce{|acc, slice| acc.map{|a| a}.zip(slice.reverse)}
    .map{|f| if f.kind_of?(Array) then f.flatten else [f] end} [thread_index]

  if    specs.nil?            then []
  elsif specs.kind_of?(Array) then specs.compact
  end
end

def sort_by_size(specs) # descending
  specs
    .map{|f| if File.file?(f) then f else nil end}
    .compact
    .map{|f| [f, File.size(f)]}
    .sort_by{|a| a[1]}.map{|a| a[0]}.reverse
end

def run(thread_index)
  report_path = ENV["REPORT_PATH"] || "#{ENV["HOME"]}/rspec_report.json"
  spec_path = ENV["SPEC_PATH"] || "spec"

  with_fallback do
    rspec_report = JSON.parse(File.read(report_path))
    thread_count = rspec_report.count
    thread = rspec_report[thread_index]

    all_specs = Dir["#{spec_path}/**/*_spec.rb"].sort
    all_known_specs = rspec_report.map { |t| t["files"] }.flatten.sort

    all_leftover_specs = all_specs - all_known_specs
    thread_leftover_specs = select_leftover_specs(all_leftover_specs, thread_count, thread_index)
    thread_specs = all_specs & thread["files"].sort
    specs_to_run = thread_specs + thread_leftover_specs

    display_files("Thread specs:", thread_specs)
    display_files("Thread leftover specs:", thread_leftover_specs)
    display_files("All leftover specs:", all_leftover_specs)
    display_files("To run:", specs_to_run)

    specs_to_run
  end
end

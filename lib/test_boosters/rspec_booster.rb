require "json"
require "test_boosters/cli_parser"
require "test_boosters/logger"
require "test_boosters/executor"

class RspecBooster
  Error = -1

  def initialize(thread_index)
    @thread_index = thread_index
    @report_path = ENV["REPORT_PATH"] || "#{ENV["HOME"]}/rspec_report.json"
    @spec_path = ENV["SPEC_PATH"] || "spec"
  end

  def run
    specs_to_run = select

    if specs_to_run == Error
      if @thread_index == 0
        execute("bundle exec rspec #{@spec_path}")
      end
    elsif specs_to_run.empty?
        puts "No spec files in this thread!"
    else
      execute("bundle exec rspec #{specs_to_run.join(" ")}")
    end
  end

  def select
    with_fallback do
      rspec_report = JSON.parse(File.read(@report_path))
      thread_count = rspec_report.count
      thread = rspec_report[@thread_index]

      all_specs = Dir["#{@spec_path}/**/*_spec.rb"].sort
      all_known_specs = rspec_report.map { |t| t["files"] }.flatten.sort

      all_leftover_specs = all_specs - all_known_specs
      thread_leftover_specs = select_leftover_specs(all_leftover_specs, thread_count)
      thread_specs = all_specs & thread["files"].sort
      specs_to_run = thread_specs + thread_leftover_specs

      display_files("This thread specs:", thread_specs)
      display_files("This thread leftover specs:", thread_leftover_specs)
      display_files("All leftover specs:", all_leftover_specs)

      specs_to_run
    end
  end

  def select_leftover_specs(all_leftover_specs, thread_count)
    all_leftover_specs = sort_by_size(all_leftover_specs)

    return [] if all_leftover_specs.empty?

    specs = all_leftover_specs
      .each_slice(thread_count)
      .reduce{|acc, slice| acc.map{|a| a}.zip(slice.reverse)}
      .map{|f| if f.kind_of?(Array) then f.flatten else [f] end} [@thread_index]

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


  def display_files(title, files)
    puts "#{title} #{files.count}\n"

    files.each { |file| puts "- #{file}" }

    puts "\n"
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

    Error
  end

end

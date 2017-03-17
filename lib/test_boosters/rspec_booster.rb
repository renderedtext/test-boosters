module TestBoosters
  class RspecBooster
    attr_reader :report_path

    def initialize(thread_index)
      @thread_index = thread_index
      @report_path = ENV["REPORT_PATH"] || "#{ENV["HOME"]}/rspec_report.json"

      @specs = TestBoosters::RSpec::Specs.new(@thread_index)
    end

    def run
      puts "========================= RSpec Booster =========================="
      puts

      puts "Known specs for this thread (#{specs.known_specs_for_current_thread.count} files):"
      spec.known_specs_for_current_thread.each { |file| puts "- #{file}" }
      puts

      puts "Leftover specs for this thread: (#{specs.leftover_specs_for_current_thread.count} files):"
      spec.leftover_specs_for_current_thread.each { |file| puts "- #{file}" }
      puts

      puts "RSpec options: #{rspec_options}"
      puts
      puts "========================= Running Rspec =========================="
      puts

      TestBoosters::Shell.execute(rspec_command)
    end

    def rspec_command
      "bundle exec rspec #{options} #{specs.for_thread.join(" ")}"
    end

    def rspec_options
      "--format documentation --format json --out #{@report_path}"
    end

  end
end

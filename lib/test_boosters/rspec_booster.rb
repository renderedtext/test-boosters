module TestBoosters
  class RspecBooster
    attr_reader :report_path

    def initialize(thread_index)
      @thread_index = thread_index
      @report_path = ENV["REPORT_PATH"] || "#{ENV["HOME"]}/rspec_report.json"

      @specs = TestBoosters::RSpec::Specs.new(@thread_index)
    end

    def run
      TestBoosters::Shell.display_title("RSpec Booster")

      TestBoosters::Shell.display_files("Known specs for this thread", specs.known_specs_for_current_thread)
      TestBoosters::Shell.display_files("Leftover specs for this thread", specs.leftover_specs_for_current_thread)

      puts "RSpec options: #{rspec_options}"

      TestBoosters::Shell.display_title("Running RSpec")

      exit_status = TestBoosters::Shell.execute(rspec_command)

      TestBoosters::Shell.display_title("Uploading Report")

      TestBoosters::InsightsUploader.new.upload("rspec", report_path)

      exit_status
    end

    def rspec_command
      "bundle exec rspec #{options} #{specs.for_thread.join(" ")}"
    end

    def rspec_options
      "--format documentation --format json --out #{@report_path}"
    end

  end
end

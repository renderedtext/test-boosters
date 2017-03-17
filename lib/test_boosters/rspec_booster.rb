module TestBoosters
  class RspecBooster
    attr_reader :report_path

    def initialize(thread_index)
      @thread_index = thread_index
      @report_path = ENV["REPORT_PATH"] || "#{ENV["HOME"]}/rspec_report.json"
      @spec_path = ENV["SPEC_PATH"] || "spec"
    end

    def run
      exit_code = true
      begin
        specs_to_run = select

        if specs_to_run.empty?
          puts "No spec files in this thread!"
        else
          exit_code = run_command(specs_to_run.join(" "))
        end
      rescue StandardError => e
        if @thread_index == 0
          exit_code = run_command(@spec_path)
        end
      end
      exit_code
    end

    def run_command(specs)
      options = "--format documentation --format json --out #{@report_path}"
      puts "Rspec options: #{options}"
      puts
      puts "========================= Running Rspec =========================="
      puts

      TestBoosters::Shell.execute("bundle exec rspec #{options} #{specs}")
    end

    def select
      with_fallback do
        split_configuration = TestBoosters::SplitConfiguration.for_rspec
        thread_count = split_configuration.threads.count

        puts "Running RSpec thread #{@thread_index + 1} out of #{thread_count} threads\n"

        all_specs = Dir["#{@spec_path}/**/*_spec.rb"].sort
        all_known_specs = split_configuration.all_files

        all_leftover_specs = all_specs - all_known_specs
        thread_leftover_specs = TestBoosters::LeftoverFiles.select(all_leftover_specs, thread_count, @thread_index)

        thread_specs = all_specs & split_configuration.files_for_thread(@thread_index)
        specs_to_run = thread_specs + thread_leftover_specs

        TestBoosters::Shell.display_files("This thread specs:", thread_specs)
        TestBoosters::Shell.display_title_and_count("All leftover specs:", all_leftover_specs)
        TestBoosters::Shell.display_files("This thread leftover specs:", thread_leftover_specs)

        specs_to_run
      end
    end

    def with_fallback
      yield
    rescue StandardError => e
      error = %{
        WARNING: An error detected while parsing the test boosters report file.
        WARNING: All tests will be executed on the first thread.\n
      }

      error += %{Exception: #{e.message}\n#{e.backtrace.join("\n")}}

      puts error
      TestBoosters::Logger.error(error)

      raise
    end

  end
end

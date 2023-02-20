module TestBoosters
  module Shell
    module_function

    # :reek:TooManyStatements
    def execute(command, options = {})
      TestBoosters::Logger.info("Running command: #{command}")

      puts command unless options[:silent] == true

      with_clean_env do
        system(command)
      end

      signaled    = $?.signaled?
      termsig     = $?.termsig
      exited      = $?.exited?
      exit_status = $?.exitstatus

      TestBoosters::Logger.info("Command signaled with: #{termsig}") if signaled
      TestBoosters::Logger.info("Command exited : #{exited}")
      TestBoosters::Logger.info("Command finished, exit status : #{exit_status}")

      exit_status
    end

    def evaluate(command)
      with_clean_env { `#{command}` }
    end

    def with_clean_env
      defined?(Bundler) ? Bundler.with_original_env { yield } : yield
    end

    def display_title(title)
      puts
      puts "=== #{title} ===="
      puts
    end

    def display_files(title, files)
      puts "#{title} (#{files.count} files):"
      puts

      files.each { |file| puts "- #{file}" }

      puts "\n"
    end

  end
end

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

    # NOTE: unlike `execute`, `evaluate` deliberately runs in the *current* bundle
    # context (no `with_clean_env`). It is used only for diagnostic version reporting
    # (see TestBoosters::ProjectInfo), where we want the versions resolved by the
    # project's active bundle. `execute` keeps `with_clean_env` because it shells out
    # to the user's actual test command, which must not inherit our Bundler env.
    def evaluate(command)
      `#{command}`
    end

    def with_clean_env
      if defined?(Bundler)
        if Bundler.respond_to?(:with_unbundled_env)
          Bundler.with_unbundled_env { yield }
        else
          Bundler.with_clean_env { yield }
        end
      else
        yield
      end
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

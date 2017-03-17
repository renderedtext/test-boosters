module TestBoosters
  module Shell
    module_function

    def execute(command)
      TestBoosters::Logger.info("Running command: #{command}")

      system(command)

      exit_status = $?.exitstatus

      TestBoosters::Logger.info("Command finished, exit status : #{exit_status}")

      exit_status
    end

    def display_title(title)
      puts
      puts "========================= #{title} =========================="
      puts
    end

    def display_files(title, files)
      puts "#{title} (#{files.count} files):"
      puts

      files.each { |file| puts "- #{file}" }

      puts "\n"
    end

    def display_title_and_count(title, files)
      puts "#{title} #{files.count}\n"
    end

  end
end

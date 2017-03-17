module Semaphore
  module Logger
    module_function

    def display_files(title, files)
      display_title_and_count(title, files)

      files.each { |file| puts "- #{file}" }

      puts "\n"
    end

    def display_title_and_count(title, files)
      puts "#{title} #{files.count}\n"
    end

  end
end

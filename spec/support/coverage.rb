module Support
  module Coverage
    module_function

    def display(coverage)
      puts
      puts "============== Coverate Score ======================"

      coverage.files.sort_by(&:covered_percent).each do |file|
        relative_filename = file.filename.gsub("#{Dir.pwd}/", "")

        puts "#{format_percentage(file.covered_percent)}: #{relative_filename}"
      end

      puts

      puts "#{format_percentage(coverage.covered_percent)}: Total"

      puts "===================================================="
    end

    def format_percentage(percentage)
      "%6.2f" % percentage
    end

  end
end

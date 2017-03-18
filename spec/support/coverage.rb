module Support
  module Coverage
    module_function

    def display(coverage)
      puts "\n============== Coverage Score ======================"

      display_files(coverage)

      puts "\n#{format_percentage(coverage.covered_percent)}: Total"

      puts "===================================================="
    end

    def display_files(coverage)
      coverage.files.sort_by(&:covered_percent).each do |file|
        relative_filename = file.filename.gsub("#{Dir.pwd}/", "")

        puts "#{format_percentage(file.covered_percent)}: #{relative_filename}"
      end
    end

    def format_percentage(percentage)
      format("%6.2f", percentage)
    end

  end
end

module TestBoosters
  module ProjectInfo
    module_function

    def display_ruby_version
      version = `ruby --version`.gsub("ruby ", "")

      puts "Ruby Version: #{version}"
    end

    def display_bundler_version
      version = `bundle --version`.gsub("Bundler version ", "")

      puts "Bundler Version: #{version}"
    end

    def display_rspec_version
      version = `bundle exec rspec --version`

      puts "RSpec Version: #{version}"
    end

    def display_cucumber_version
      version = `bundle exec cucumber --version`

      puts "Cucumber Version: #{version}"
    end

    def display_split_configuration_info(split_configuration)
      puts "Split configuration present: #{split_configuration.present? ? "yes" : "no"}"
      puts "Split configuration valid: #{split_configuration.valid? ? "yes" : "no"}"
      puts "Split configuration file count: #{split_configuration.all_files.size}"
    end

  end
end

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

  end
end

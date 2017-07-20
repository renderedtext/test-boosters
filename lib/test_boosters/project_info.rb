module TestBoosters
  module ProjectInfo
    module_function

    def display_ruby_version
      version = TestBoosters::Shell.evaluate("ruby --version").gsub("ruby ", "")

      puts "Ruby Version: #{version}"
    end

    def display_bundler_version
      version = TestBoosters::Shell.evaluate("bundle --version").gsub("Bundler version ", "")

      puts "Bundler Version: #{version}"
    end

    def display_rspec_version
      command = "(bundle list | grep -q '* rspec') && (bundle exec rspec --version | head -1) || echo 'not found'"
      version = TestBoosters::Shell.evaluate(command)

      puts "RSpec Version: #{version}"
    end

    def display_cucumber_version
      command = "(bundle list | grep -q '* cucumber') && (bundle exec cucumber --version | head -1) || echo 'not found'"
      version = TestBoosters::Shell.evaluate(command)

      puts "Cucumber Version: #{version}"
    end

  end
end

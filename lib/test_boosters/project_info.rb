module TestBoosters
  module ProjectInfo
    module_function

    def display_ruby_version
      version = evaluate("ruby --version").gsub("ruby ", "")

      puts "Ruby Version: #{version}"
    end

    def display_bundler_version
      version = evaluate("bundle --version").gsub("Bundler version ", "")

      puts "Bundler Version: #{version}"
    end

    def display_rspec_version
      version = evaluate("(bundle list | grep -q '* rspec') && bundle exec rspec --version || echo 'not found'")

      puts "RSpec Version: #{version}"
    end

    def display_cucumber_version
      version = evaluate("(bundle list | grep -q '* cucumber') && bundle exec cucumber --version || echo 'not found'")

      puts "Cucumber Version: #{version}"
    end

    def evaluate(command)
      Bundler.with_clean_env { `#{command}` }
    end

  end
end

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
      # rubocop:disable Metrics/LineLength
      command = %q(bundle exec ruby -e 'spec = Gem::Specification.find_all_by_name("rspec-core").first; puts(spec ? "RSpec #{spec.version}" : "not found")')
      # rubocop:enable Metrics/LineLength
      version = TestBoosters::Shell.evaluate(command)

      puts "RSpec Version: #{version}"
    end

    def display_cucumber_version
      # rubocop:disable Metrics/LineLength
      command = %q(bundle exec ruby -e 'spec = Gem::Specification.find_all_by_name("cucumber").first; puts(spec ? spec.version.to_s : "not found")')
      # rubocop:enable Metrics/LineLength
      version = TestBoosters::Shell.evaluate(command)

      puts "Cucumber Version: #{version}"
    end

  end
end

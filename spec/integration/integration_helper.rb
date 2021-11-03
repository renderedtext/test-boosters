module IntegrationHelper
  class TestRepo

    REPO = "https://github.com/renderedtext/test-boosters-tests.git".freeze

    attr_reader :project_path

    def initialize(test_project)
      @repo_path = "/tmp/test-boosters-tests"
      @project_path = "/tmp/test-boosters-tests/#{test_project}"
      @env = ""
    end

    def clone
      puts "Cloning Repo"
      system("[ ! -e #{@repo_path} ] && git clone #{REPO} #{@repo_path}")
    end

    def set_env_var(name, value)
      @env += "#{name}=#{value} "
    end

    def use_cucumber_config(file)
      file_exists = File.file?("#{@project_path}/config/#{file}")
      raise "#{file} doesn't exist. Please use existing configuration yaml." unless file_exists

      system("cp #{@project_path}/config/#{file} #{@project_path}/config/cucumber.yml")
    end

    # :reek:TooManyStatements
    def run_command(command)
      Bundler.with_original_env do
        cmd = "cd #{@project_path} && #{@env} #{command}"

        puts "Running: #{cmd}"

        output = `#{cmd}`

        puts output

        output
      end
    end

    def run_booster(command)
      run_command("BUNDLE_GEMFILE=#{Dir.pwd}/Gemfile bundle exec #{command}")
    end
  end
end

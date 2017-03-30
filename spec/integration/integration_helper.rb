module IntegrationHelper
  class TestRepo

    REPO = "https://github.com/renderedtext/test-boosters-tests.git".freeze

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

    # :reek:TooManyStatements
    def run_command(command)
      Bundler.with_clean_env do
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

require "spec_helper"
require_relative "./integration_helper"

describe "RSpec Booster", :integration do

  shared_examples "an rspec booster" do |options|
    before(:all) do
      @rspec_version = options.fetch(:rspec_version)

      puts "======================================================================"
      puts "Testing RSpec Booster with RSpec version #{@rspec_version}            "
      puts "======================================================================"

      @split_configuration_path = "/tmp/rspec_split_configuration.json"

      @test_repo = IntegrationHelper::TestRepo.new("rspec_project")
      @test_repo.clone
      @test_repo.set_env_var("RSPEC_SPLIT_CONFIGURATION_PATH", @split_configuration_path)

      # set RSpec version in the test project
      rspec_dependancy_pattern = 'spec.add_development_dependency "rspec".*$'
      rspec_dependancy_version = "spec.add_development_dependency \"rspec\", '#{@rspec_version}'"
      gemspec_path = "#{@test_repo.project_path}/rspec_project.gemspec"
      system(%{sed -i 's/#{rspec_dependancy_pattern}/#{rspec_dependancy_version}/' #{gemspec_path}})

      File.write(@split_configuration_path, [
        { :files => [] },
        { :files => ["spec/lib/a_spec.rb"] }
      ].to_json)

      @test_repo.run_command("bundle install --path vendor/bundle")
    end

    before { FileUtils.rm_f("#{ENV["HOME"]}/rspec_report.json") }

    specify "first job's behaviour" do
      output = @test_repo.run_booster("rspec_booster --job 1/3")

      expect(output).to include("3 examples, 1 failure")
      expect($?.exitstatus).to eq(1)

      expect(File).to exist("#{ENV["HOME"]}/rspec_report.json")
    end

    specify "second job's behaviour" do
      output = @test_repo.run_booster("rspec_booster --job 2/3")

      expect(output).to include("1 example, 0 failures")
      expect($?.exitstatus).to eq(0)

      expect(File).to exist("#{ENV["HOME"]}/rspec_report.json")
    end

    specify "third job's behaviour" do
      output = @test_repo.run_booster("rspec_booster --job 3/3")

      expect(output).to include("No files to run in this job!")
      expect($?.exitstatus).to eq(0)

      expect(File).to_not exist("#{ENV["HOME"]}/rspec_report.json")
    end

    specify "rspec_report format" do
      @test_repo.run_booster("rspec_booster --job 1/3")

      report = JSON.parse(File.read("#{ENV["HOME"]}/rspec_report.json"))
      expected = JSON.parse(File.read("spec/expected_rspec_report_format.json"))

      # ignore actual runtimes
      report["examples"].each { |e| e["run_time"] = 0 }
      expected["examples"].each { |e| e["run_time"] = 0 }

      expect(report).to eq(expected)
    end
  end

  it_behaves_like "an rspec booster", :rspec_version => 3.6
  it_behaves_like "an rspec booster", :rspec_version => 3.5
  it_behaves_like "an rspec booster", :rspec_version => 3.4
  it_behaves_like "an rspec booster", :rspec_version => 3.3
  it_behaves_like "an rspec booster", :rspec_version => 3.2
  it_behaves_like "an rspec booster", :rspec_version => 3.1
  it_behaves_like "an rspec booster", :rspec_version => 3.0

end

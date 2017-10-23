require "spec_helper"
require_relative "./integration_helper"

describe "Cucumber Booster", :integration do

  before(:all) do
    @split_configuration_path = "/tmp/cucumber_split_configuration.json"

    @test_repo = IntegrationHelper::TestRepo.new("cucumber_project")
    @test_repo.clone
    @test_repo.set_env_var("CUCUMBER_SPLIT_CONFIGURATION_PATH", @split_configuration_path)
    @test_repo.use_cucumber_config("cucumber.yml.empty")

    File.write(@split_configuration_path, [
      { :files => [] },
      { :files => ["features/a.feature"] }
    ].to_json)

    @test_repo.run_command("bundle install --path vendor/bundle")
  end

  before { FileUtils.rm_f("#{ENV["HOME"]}/cucumber_report.json") }

  specify "first job's behaviour" do
    output = @test_repo.run_booster("cucumber_booster --job 1/3")

    expect(output).to include("1 scenario (1 passed)")
    expect($?.exitstatus).to eq(0)

    expect(File).to exist("#{ENV["HOME"]}/cucumber_report.json")
  end

  specify "second job's behaviour" do
    output = @test_repo.run_booster("cucumber_booster --job 2/3")

    expect(output).to include("2 scenarios (2 failed)")
    expect($?.exitstatus).to eq(1)

    expect(File).to exist("#{ENV["HOME"]}/cucumber_report.json")
  end

  specify "third job's behaviour" do
    output = @test_repo.run_booster("cucumber_booster --job 3/3")

    expect(output).to include("No files to run in this job!")
    expect($?.exitstatus).to eq(0)

    expect(File).to_not exist("#{ENV["HOME"]}/cucumber_report.json")
  end

end

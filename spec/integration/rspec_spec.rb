require "spec_helper"
require_relative "./integration_helper"

describe "RSpec Booster", :integration do

  before(:all) do
    @split_configuration_path = "/tmp/rspec_split_configuration.json"

    @test_repo = IntegrationHelper::TestRepo.new("rspec_project")
    @test_repo.clone
    @test_repo.set_env_var("RSPEC_SPLIT_CONFIGURATION_PATH", @split_configuration_path)

    File.write(@split_configuration_path, [
      { :files => [] },
      { :files => ["spec/lib/a_spec.rb"] }
    ].to_json)

    @test_repo.run_command("bundle install --path vendor/bundle")
  end

  before { FileUtils.rm_f("#{ENV["HOME"]}/rspec_report.json") }

  specify "first job's behaviour" do
    output = @test_repo.run_booster("rspec_booster --job 1/3")

    expect(output).to include("2 examples, 1 failure")
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

end

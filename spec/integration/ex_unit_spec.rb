require "spec_helper"
require_relative "./integration_helper"

describe "ExUnit Booster", :integration do

  before(:all) do
    @split_configuration_path = "/tmp/ex_unit_split_configuration.json"

    @test_repo = IntegrationHelper::TestRepo.new("ex_unit_project")
    @test_repo.clone
    @test_repo.set_env_var("EX_UNIT_SPLIT_CONFIGURATION_PATH", @split_configuration_path)

    File.write(@split_configuration_path, [
      { :files => [] },
      { :files => ["test/lib/a_test.exs"] }
    ].to_json)
  end

  specify "first job's behaviour" do
    output = @test_repo.run_booster("ex_unit_booster --job 1/3")

    expect(output).to include("1 test, 0 failure")
    expect($?.exitstatus).to eq(0)
  end

  specify "second job's behaviour" do
    output = @test_repo.run_booster("ex_unit_booster --job 2/3")

    expect(output).to include("1 test, 1 failure")
    expect($?.exitstatus).to eq(1)
  end

  specify "third job's behaviour" do
    output = @test_repo.run_booster("ex_unit_booster --job 3/3")

    expect(output).to include("No files to run in this job!")
    expect($?.exitstatus).to eq(0)
  end

end

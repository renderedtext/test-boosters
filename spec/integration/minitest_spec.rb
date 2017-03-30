require "spec_helper"
require_relative "./integration_helper"

describe "Minitest Booster", :integration do

  before(:all) do
    @split_configuration_path = "/tmp/minitest_split_configuration.json"

    @test_repo = IntegrationHelper::TestRepo.new("minitest_project")
    @test_repo.clone
    @test_repo.set_env_var("MINITEST_SPLIT_CONFIGURATION_PATH", @split_configuration_path)

    File.write(@split_configuration_path, [
      { :files => [] },
      { :files => ["test/a_test.rb"] }
    ].to_json)

    @test_repo.run_command("bundle install --path vendor/bundle")
  end

  specify "first job's behaviour" do
    output = @test_repo.run_booster("minitest_booster --job 1/3")

    expect(output).to include("1 runs, 1 assertions, 1 failures, 0 errors, 0 skips")
    expect($?.exitstatus).to eq(1)
  end

  specify "second job's behaviour" do
    output = @test_repo.run_booster("minitest_booster --job 2/3")

    expect(output).to include("2 runs, 2 assertions, 1 failures, 0 errors, 0 skips")
    expect($?.exitstatus).to eq(1)
  end

  specify "third job's behaviour" do
    output = @test_repo.run_booster("minitest_booster --job 3/3")

    expect(output).to include("No files to run in this job!")
    expect($?.exitstatus).to eq(0)
  end

end

require "spec_helper"

describe "ExUnit Booster", :integration do

  before(:all) do
    @repo_path = "/tmp/test-boosters-tests"
    @project_path = "/tmp/test-boosters-tests/ex_unit_project"
    @split_configuration_path = "/tmp/ex_unit_split_configuration.json"

    ENV["RSPEC_SPLIT_CONFIGURATION_PATH"] = @split_configuration_path

    File.write(@split_configuration_path, [
      { :files => [] },
      { :files => ["test/lib/a_test.exs"] }
    ].to_json)

    system("[ ! -e #{@repo_path} ] && git clone https://github.com/renderedtext/test-boosters-tests.git #{@repo_path}")
  end

  specify "first job's behaviour" do
    output = `cd #{@project_path} && ex_unit_booster --job 1/3`

    expect(output).to include("1 test, 0 failure")
    expect($?.exitstatus).to eq(0)
  end

  specify "second job's behaviour" do
    output = `cd #{@project_path} && ex_unit_booster --job 2/3`

    expect(output).to include("1 test, 1 failure")
    expect($?.exitstatus).to eq(1)
  end

  specify "third job's behaviour" do
    output = `cd #{@project_path} && ex_unit_booster --job 3/3`

    expect(output).to include("No files to run in this job!")
    expect($?.exitstatus).to eq(0)
  end

end

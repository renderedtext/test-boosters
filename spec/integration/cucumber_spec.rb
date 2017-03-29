require "spec_helper"

describe "Cucumber Booster" do

  before(:all) do
    @repo_path = "/tmp/test-boosters-tests"
    @project_path = "/tmp/test-boosters-tests/cucumber_project"
    @split_configuration_path = "/tmp/cucumber_split_configuration.json"

    ENV["CUCUMBER_SPLIT_CONFIGURATION_PATH"] = @split_configuration_path

    File.write(@split_configuration_path, [
      { :files => [] },
      { :files => ["features/a.feature"] }
    ].to_json)

    system("[ ! -e #{@repo_path} ] && git clone https://github.com/renderedtext/test-boosters-tests.git #{@repo_path}")
    system("cd #{@project_path} && bundle install --path vendor/bundle")
  end

  before { FileUtils.rm_f("#{ENV["HOME"]}/cucumber_report.json") }

  specify "first job's behaviour" do
    output = `cd #{@project_path} && cucumber_booster --job 1/3`

    expect(output).to include("2 examples, 1 failure")
    expect($?.exitstatus).to eq(1)

    expect(File).to exist("#{ENV["HOME"]}/cucumber_report.json")
  end

  specify "second job's behaviour" do
    output = `cd #{@project_path} && cucumber_booster --job 2/3`

    expect(output).to include("1 example, 0 failures")
    expect($?.exitstatus).to eq(0)

    expect(File).to exist("#{ENV["HOME"]}/cucumber_report.json")
  end

  specify "third job's behaviour" do
    output = `cd #{@project_path} && cucumber_booster --job 3/3`

    expect(output).to include("No files to run in this job!")
    expect($?.exitstatus).to eq(0)

    expect(File).to_not exist("#{ENV["HOME"]}/cucumber_report.json")
  end

end

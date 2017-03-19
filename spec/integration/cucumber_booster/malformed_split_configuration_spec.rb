require "spec_helper"

describe "Cucumber Booster behvaviour when split configuration is malformed" do

  let(:specs_path) { "features" }
  let(:split_configuration_path) { "/tmp/cucumber_split_configuration.json" }
  let(:cucumber_report_path) { "/tmp/cucumber_report.json" }

  before do
    # Set up environment variables
    ENV["SPEC_PATH"] = specs_path
    ENV["CUCUMBER_SPLIT_CONFIGURATION_PATH"] = split_configuration_path
    ENV["REPORT_PATH"] = cucumber_report_path

    # set up features directory
    FileUtils.rm_f(cucumber_report_path)
    FileUtils.rm_rf("features")
    FileUtils.mkdir_p("features")
    FileUtils.rm_rf("config")
    FileUtils.mkdir_p("config")
    File.write("config/cucumber.yml", "default: --format pretty\n")

    # Create spec files
    Support::CucumberFilesFactory.create(:name => "A", :path => "#{specs_path}/a.feature")
    Support::CucumberFilesFactory.create(:name => "B", :path => "#{specs_path}/b.feature")
    Support::CucumberFilesFactory.create(:name => "C", :path => "#{specs_path}/admin/c.feature")

    # Construct broken split configuration
    File.write(split_configuration_path, { :lol => :malformed }.to_json)

    # make sure that everything is set up as it should be
    expect(File.exist?(cucumber_report_path)).to eq(false)

    expect(File.exist?(split_configuration_path)).to eq(true)

    expect(Dir["#{specs_path}/**/*"].sort).to eq([
      "#{specs_path}/a.feature",
      "#{specs_path}/admin",
      "#{specs_path}/admin/c.feature",
      "#{specs_path}/b.feature",
      "#{specs_path}/step_definitions",
      "#{specs_path}/step_definitions/a_step.rb",
      "#{specs_path}/step_definitions/b_step.rb",
      "#{specs_path}/step_definitions/c_step.rb"
    ])
  end

  specify "first thread's behaviour" do
    output = `cucumber_booster --thread 1`

    expect(output).to include("[ERROR] The split configuration file is malformed!")
    expect($?.exitstatus).to eq(1)

    expect(File.exist?(cucumber_report_path)).to eq(false)
  end

  specify "second thread's behaviour" do
    output = `cucumber_booster --thread 2`

    expect(output).to include("[ERROR] The split configuration file is malformed!")
    expect($?.exitstatus).to eq(1)

    expect(File.exist?(cucumber_report_path)).to eq(false)
  end

  specify "third thread's behaviour" do
    output = `cucumber_booster --thread 3`

    expect(output).to include("[ERROR] The split configuration file is malformed!")
    expect($?.exitstatus).to eq(1)

    expect(File.exist?(cucumber_report_path)).to eq(false)
  end

end

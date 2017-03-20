require "spec_helper"

describe "Cucumber Booster behvaviour there are no spec files" do

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

    # Construct a split configuration
    File.write(split_configuration_path, [
      { :files => ["#{specs_path}/a.feature"] },
      { :files => ["#{specs_path}/b.feature"] },
      { :files => [] }
    ].to_json)

    # make sure that everything is set up as it should be
    expect(File.exist?(cucumber_report_path)).to eq(false)

    expect(File.exist?(split_configuration_path)).to eq(true)

    expect(Dir["#{specs_path}/**/*"].sort).to eq([])
  end

  specify "first thread's behaviour" do
    output = `cucumber_booster --thread 1/3`

    expect($?.exitstatus).to eq(0)
    expect(output).to include("No files to run in this thread!")

    expect(File.exist?(cucumber_report_path)).to eq(false)
  end

  specify "second thread's behaviour" do
    output = `cucumber_booster --thread 2/3`

    expect($?.exitstatus).to eq(0)
    expect(output).to include("No files to run in this thread!")

    expect(File.exist?(cucumber_report_path)).to eq(false)
  end

  specify "third thread's behaviour" do
    output = `cucumber_booster --thread 3/3`

    expect($?.exitstatus).to eq(0)
    expect(output).to include("No files to run in this thread!")

    expect(File.exist?(cucumber_report_path)).to eq(false)
  end

end

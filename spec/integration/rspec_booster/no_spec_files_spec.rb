require "spec_helper"

describe "RSpec Booster behvaviour there are no spec files" do

  let(:project_path) { "/tmp/project_path-#{SecureRandom.uuid}" }
  let(:specs_path) { "#{project_path}/spec" }
  let(:split_configuration_path) { "/tmp/rspec_split_configuration.json" }
  let(:rspec_report_path) { "/tmp/rspec_report.json" }

  before do
    # Set up environment variables
    ENV["SPEC_PATH"] = specs_path
    ENV["RSPEC_SPLIT_CONFIGURATION_PATH"] = split_configuration_path
    ENV["REPORT_PATH"] = rspec_report_path

    # Set up test dir structure
    FileUtils.rm_rf(specs_path)
    FileUtils.mkdir_p(specs_path)
    FileUtils.rm_f(rspec_report_path)

    # Construct a split configuration
    File.write(split_configuration_path, [
      { :files => ["#{specs_path}/a_spec.rb"] },
      { :files => ["#{specs_path}/b_spec.rb"] },
      { :files => [] }
    ].to_json)

    # make sure that everything is set up as it should be
    expect(File.exist?(rspec_report_path)).to eq(false)

    expect(File.exist?(split_configuration_path)).to eq(true)

    expect(Dir["#{specs_path}/**/*"].sort).to eq([])
  end

  specify "first thread's behaviour" do
    output = `cd #{project_path} && rspec_booster --thread 1`

    expect($?.exitstatus).to eq(0)
    expect(output).to include("No files to run in this thread!")

    expect(File.exist?(rspec_report_path)).to eq(false)
  end

  specify "second thread's behaviour" do
    output = `cd #{project_path} && rspec_booster --thread 2`

    expect($?.exitstatus).to eq(0)
    expect(output).to include("No files to run in this thread!")

    expect(File.exist?(rspec_report_path)).to eq(false)
  end

  specify "third thread's behaviour" do
    output = `cd #{project_path} && rspec_booster --thread 3`

    expect($?.exitstatus).to eq(0)
    expect(output).to include("No files to run in this thread!")

    expect(File.exist?(rspec_report_path)).to eq(false)
  end

end

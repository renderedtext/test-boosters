require "spec_helper"

describe "RSpec Booster behvaviour when split configuration is malformed" do

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

    # Create spec files
    Support::RspecFilesFactory.create(:path => "#{specs_path}/a_spec.rb", :result => :passing)
    Support::RspecFilesFactory.create(:path => "#{specs_path}/b_spec.rb", :result => :passing)
    Support::RspecFilesFactory.create(:path => "#{specs_path}/lib/c_spec.rb", :result => :passing)

    # Construct spec helper file
    File.write("#{specs_path}/spec_helper.rb", "")

    # Construct a broken split configuration
    File.write(split_configuration_path, { :lol => "Batman is stronger than Superman" }.to_json)

    # make sure that everything is set up as it should be
    expect(File.exist?(rspec_report_path)).to eq(false)

    expect(File.exist?(split_configuration_path)).to eq(true)

    expect(Dir["#{specs_path}/**/*"].sort).to eq([
      "#{specs_path}/a_spec.rb",
      "#{specs_path}/b_spec.rb",
      "#{specs_path}/lib",
      "#{specs_path}/lib/c_spec.rb",
      "#{specs_path}/spec_helper.rb"
    ])
  end

  specify "first job's behaviour" do
    output = `cd #{project_path} && rspec_booster --job 1/3`

    expect(output).to include("1 example, 0 failure")
    expect($?.exitstatus).to eq(0)

    expect(File.exist?(rspec_report_path)).to eq(true)
  end

  specify "second job's behaviour" do
    output = `cd #{project_path} && rspec_booster --job 2/3`

    expect(output).to include("1 example, 0 failure")
    expect($?.exitstatus).to eq(0)

    expect(File.exist?(rspec_report_path)).to eq(true)
  end

  specify "third job's behaviour" do
    output = `cd #{project_path} && rspec_booster --job 3/3`

    expect(output).to include("1 example, 0 failure")
    expect($?.exitstatus).to eq(0)

    expect(File.exist?(rspec_report_path)).to eq(true)
  end

end

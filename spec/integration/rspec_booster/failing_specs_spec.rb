require "spec_helper"

describe "RSpec Booster behvaviour when the tests fail" do

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
    Support::RspecFilesFactory.create(:path => "#{specs_path}/a_spec.rb", :result => :failing)
    Support::RspecFilesFactory.create(:path => "#{specs_path}/b_spec.rb", :result => :failing)
    Support::RspecFilesFactory.create(:path => "#{specs_path}/lib/c_spec.rb", :result => :passing)

    # Construct spec helper file
    File.write("#{specs_path}/spec_helper.rb", "")

    # Construct a split configuration
    File.write(split_configuration_path, [
      { :files => ["#{specs_path}/a_spec.rb"] },
      { :files => ["#{specs_path}/b_spec.rb"] },
      { :files => [] }
    ].to_json)

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

  specify "first thread's behaviour" do
    output = `cd #{project_path} && rspec_booster --thread 1/3`

    expect(output).to include("2 examples, 1 failure")
    expect($?.exitstatus).to eq(1)

    expect(File.exist?(rspec_report_path)).to eq(true)
  end

  specify "second thread's behaviour" do
    output = `cd #{project_path} && rspec_booster --thread 2/3`

    expect(output).to include("1 example, 1 failure")
    expect($?.exitstatus).to eq(1)

    expect(File.exist?(rspec_report_path)).to eq(true)
  end

  specify "third thread's behaviour" do
    output = `cd #{project_path} && rspec_booster --thread 3/3`

    expect(output).to include("No files to run in this thread!")
    expect($?.exitstatus).to eq(0)

    expect(File.exist?(rspec_report_path)).to eq(false)
  end

end

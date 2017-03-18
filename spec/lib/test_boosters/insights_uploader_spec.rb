require "spec_helper"

describe TestBoosters::InsightsUploader do

  it "uploads dummy json file" do
    ENV["SEMAPHORE_PROJECT_UUID"]     = "not a project UUID"
    ENV["SEMAPHORE_EXECUTABLE_UUID"]  = "not a build UUID"
    ENV["SEMAPHORE_JOB_UUID"]         = "not a job UUID"

    dymmy_json_file = "spec/dymmy_json_file.json"

    expect(TestBoosters::InsightsUploader.upload("rspec", dymmy_json_file)).to eq(0)
  end

  it "fails to upload dummy json file - no file" do
    expect(TestBoosters::InsightsUploader.upload("rspec", "no-file")).to eq(1)
  end

  it "fails to upload dummy json file - malformed file" do
    expect(TestBoosters::InsightsUploader.upload("rspec", "README.md")).to eq(1)
  end

end

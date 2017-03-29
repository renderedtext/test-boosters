require "spec_helper"

describe TestBoosters::InsightsUploader do

  before do
    @report_path = "/tmp/report.json"

    File.write(@report_path, "")
  end

  it "uploads json file" do
    ENV["SEMAPHORE_PROJECT_UUID"] = "aaaa"
    ENV["SEMAPHORE_EXECUTABLE_UUID"] = "bbbb"
    ENV["SEMAPHORE_JOB_UUID"] = "cccc"

    expect(TestBoosters::Shell).to receive(:execute).with("http POST 'https://insights-receiver.semaphoreci.com/job_reports?project_hash_id=aaaa&build_hash_id=bbbb&job_hash_id=cccc' rspec:=@/tmp/report.json > ~/insights_uploader.log", :silent => true)

    TestBoosters::InsightsUploader.upload("rspec", @report_path)
  end

end

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

    base = "https://insights-receiver.semaphoreci.com/job_reports"
    params = "project_hash_id=aaaa&build_hash_id=bbbb&job_hash_id=cccc"

    cmd = "http POST '#{base}?#{params}' rspec:=@/tmp/report.json > ~/insights_uploader.log"

    expect(TestBoosters::Shell).to receive(:execute).with(cmd, :silent => true)

    TestBoosters::InsightsUploader.upload("rspec", @report_path)
  end

  context "no report file" do
    before do
      File.delete(@report_path)
    end

    it "does nothing" do
      expect(TestBoosters::Shell).not_to receive(:execute)

      TestBoosters::InsightsUploader.upload("rspec", @report_path)
    end
  end

end

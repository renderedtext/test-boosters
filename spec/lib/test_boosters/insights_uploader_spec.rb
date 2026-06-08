require "spec_helper"

describe TestBoosters::InsightsUploader do

  # These examples mutate process-global Semaphore env vars; snapshot and restore
  # them so values don't leak into other spec files (ordering-dependent failures).
  around do |example|
    keys = %w[SEMAPHORE_PROJECT_UUID SEMAPHORE_EXECUTABLE_UUID SEMAPHORE_JOB_UUID]
    saved = keys.map { |key| [key, ENV[key]] }

    example.run

    saved.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

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

  describe ".insights_url" do
    it "includes semaphore identifiers in query params" do
      ENV["SEMAPHORE_PROJECT_UUID"] = "project-id"
      ENV["SEMAPHORE_EXECUTABLE_UUID"] = "build-id"
      ENV["SEMAPHORE_JOB_UUID"] = "job-id"

      url = described_class.insights_url

      expect(url).to include("https://insights-receiver.semaphoreci.com/job_reports?")
      expect(url).to include("project_hash_id=project-id")
      expect(url).to include("build_hash_id=build-id")
      expect(url).to include("job_hash_id=job-id")
    end
  end

end

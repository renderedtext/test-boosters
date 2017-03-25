require "spec_helper"

describe TestBoosters::Cucumber::Thread do
  let(:files_from_split_config) { ["features/a.feature", "feature/b.feature"] }
  let(:leftover_files) { ["featutes/c.feature", "feature/d.feature"] }
  let(:report_path) { "/tmp/cucumber_report.json" }

  before do
    allow($stdout).to receive(:puts)
    allow(TestBoosters::Shell).to receive(:execute)
    allow(TestBoosters::InsightsUploader).to receive(:upload)

    ENV["REPORT_PATH"] = report_path
  end

  describe "#run" do
    context "no files to run" do
      subject(:thread) { TestBoosters::Cucumber::Thread.new([], []) }

      it "displays that there are not files to run" do
        expect { thread.run }.to output(/No files to run in this thread!/).to_stdout
      end

      it "return exit status 0" do
        expect(thread.run).to eq(0)
      end

      it "doesn't try to upload cucumber report" do
        expect(TestBoosters::InsightsUploader).not_to receive(:upload)

        thread.run
      end
    end
  end

  describe "#upload_report" do
    subject(:thread) { TestBoosters::Cucumber::Thread.new([], []) }

    it "invokes the insight upload command" do
      expect(TestBoosters::InsightsUploader).to receive(:upload).with("cucumber", report_path)

      thread.upload_report
    end
  end

  describe "#run_cucumber" do
    subject(:thread) { TestBoosters::Cucumber::Thread.new(files_from_split_config, leftover_files) }

    it "displays 'running cucumber'" do
      expect { thread.run_cucumber }.to output(/Running Cucumber/).to_stdout
    end

    it "executes the cucumber command" do
      files = "#{files_from_split_config.join(" ")} #{leftover_files.join(" ")}"
      cmd = "bundle exec cucumber #{files}"

      expect(TestBoosters::Shell).to receive(:execute).with(cmd)

      thread.run_cucumber
    end
  end

  describe "#display_thread_info" do
    subject(:thread) { TestBoosters::Cucumber::Thread.new(files_from_split_config, leftover_files) }

    it "displays known specs" do
      expect { thread.display_thread_info }.to output(/Known specs for this thread/).to_stdout
    end

    it "displays leftover specs" do
      expect { thread.display_thread_info }.to output(/Leftover specs for this thread/).to_stdout
    end
  end

  describe "#run_cucumber_config" do
    subject(:thread) { TestBoosters::Cucumber::Thread.new([], []) }

    before do
      allow(CucumberBoosterConfig::CLI).to receive(:start)
    end

    it "executed the injector" do
      allow(CucumberBoosterConfig::CLI).to receive(:start).with(["inject", "."])

      thread.run_cucumber_config
    end
  end

  describe "#run" do
    subject(:thread) { TestBoosters::Cucumber::Thread.new(files_from_split_config, leftover_files) }

    it "displays information about the current thread" do
      expect(thread).to receive(:display_thread_info)

      thread.run
    end

    it "runs the cucumber config" do
      expect(thread).to receive(:run_cucumber_config)

      thread.run
    end

    it "runs the cucumber command" do
      expect(thread).to receive(:run_cucumber)

      thread.run
    end

    it "uploads the cucumber report" do
      expect(thread).to receive(:upload_report)

      thread.run
    end

    it "returns the exit status of the cucumber command" do
      allow(thread).to receive(:run_cucumber).and_return(12)

      expect(thread.run).to eq(12)
    end
  end

  describe "#all_files" do
    subject(:thread) { TestBoosters::Cucumber::Thread.new(files_from_split_config, leftover_files) }

    it "returns knows and leftover files" do
      expect(thread.all_files).to eq(files_from_split_config + leftover_files)
    end
  end

end

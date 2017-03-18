require "spec_helper"

describe TestBoosters::Rspec::Thread do
  let(:files_from_split_config) { ["spec/a_spec.rb", "spec/b_spec.rb"] }
  let(:leftover_files) { ["spec/c_spec.rb", "spec/d_spec.rb"] }
  let(:report_path) { "/tmp/rspec_report.json" }

  before do
    allow($stdout).to receive(:puts)
    allow(TestBoosters::Shell).to receive(:execute)
    allow(TestBoosters::InsightsUploader).to receive(:upload)

    ENV["REPORT_PATH"] = report_path
  end

  describe "#run" do
    context "no files to run" do
      subject(:thread) { TestBoosters::Rspec::Thread.new([], []) }

      it "displays that there are not files to run" do
        expect { thread.run }.to output(/No files to run in this thread!/).to_stdout
      end

      it "return exit status 0" do
        expect(thread.run).to eq(0)
      end

      it "doesn't try to upload rspec report" do
        expect(TestBoosters::InsightsUploader).not_to receive(:upload)

        thread.run
      end
    end
  end

  describe "#upload_report" do
    subject(:thread) { TestBoosters::Rspec::Thread.new([], []) }

    it "displays that uploading is in progress" do
      expect { thread.upload_report }.to output(/Uploading Report/).to_stdout
    end

    it "invokes the insight upload command" do
      expect(TestBoosters::InsightsUploader).to receive(:upload).with("rspec", report_path)

      thread.upload_report
    end
  end

  describe "#run_rspec" do
    subject(:thread) { TestBoosters::Rspec::Thread.new(files_from_split_config, leftover_files) }

    it "displays 'running rspec'" do
      expect { thread.run_rspec }.to output(/Running RSpec/).to_stdout
    end

    it "executes the rspec command" do
      files = "#{files_from_split_config.join(" ")} #{leftover_files.join(" ")}"
      options = "--format documentation --format json --out #{report_path}"
      cmd = "bundle exec rspec #{options} #{files}"

      expect(TestBoosters::Shell).to receive(:execute).with(cmd)

      thread.run_rspec
    end
  end

end

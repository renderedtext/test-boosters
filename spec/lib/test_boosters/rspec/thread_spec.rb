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
      options = " --format documentation --format json --out #{report_path}"
      cmd = "bundle exec rspec #{options} #{files}"

      expect(TestBoosters::Shell).to receive(:execute).with(cmd)

      thread.run_rspec
    end
  end

  describe "#display_thread_info" do
    subject(:thread) { TestBoosters::Rspec::Thread.new(files_from_split_config, leftover_files) }

    it "displays known specs" do
      expect { thread.display_thread_info }.to output(/Known specs for this thread/).to_stdout
    end

    it "displays leftover specs" do
      expect { thread.display_thread_info }.to output(/Leftover specs for this thread/).to_stdout
    end

    it "displays rspec options" do
      expect { thread.display_thread_info }.to output(/#{thread.rspec_options}/).to_stdout
    end
  end

  describe "#rspec_options" do
    subject(:thread) { TestBoosters::Rspec::Thread.new(files_from_split_config, leftover_files) }

    context "when TB_RSPEC_OPTIONS env variable is empty" do
      it "returns the default options" do
        expect(thread.rspec_options).to eq(" --format documentation --format json --out /tmp/rspec_report.json")
      end
    end

    context "when TB_RSPEC_OPTIONS env variable is present" do
      before { ENV["TB_RSPEC_OPTIONS"] = "--fail-fast=3" }
      after  { ENV.delete("TB_RSPEC_OPTIONS") }

      subject(:options) { thread.rspec_options }

      it "returns the default options with the environment variable content" do
        expect(options).to eq("--fail-fast=3 --format documentation --format json --out /tmp/rspec_report.json")
      end
    end
  end

  describe "#run" do
    subject(:thread) { TestBoosters::Rspec::Thread.new(files_from_split_config, leftover_files) }

    it "displays information about the current thread" do
      expect(thread).to receive(:display_thread_info)

      thread.run
    end

    it "runs the rspec command" do
      expect(thread).to receive(:run_rspec)

      thread.run
    end

    it "uploads the rspec report" do
      expect(thread).to receive(:upload_report)

      thread.run
    end

    it "returns the exit status of the rspec command" do
      allow(thread).to receive(:run_rspec).and_return(12)

      expect(thread.run).to eq(12)
    end
  end

  describe "#all_files" do
    subject(:thread) { TestBoosters::Rspec::Thread.new(files_from_split_config, leftover_files) }

    it "returns knows and leftover files" do
      expect(thread.all_files).to eq(files_from_split_config + leftover_files)
    end
  end

end

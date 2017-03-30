require "spec_helper"

describe TestBoosters::Job do

  before do
    allow(TestBoosters::Shell).to receive(:execute).and_return(12)
    allow(TestBoosters::Shell).to receive(:display_files)
  end

  def run
    described_class.run("bundle exec rspec", ["file1.rb"], ["file2.rb"])
  end

  describe ".run" do
    it "displays known files" do
      expect(TestBoosters::Shell).to receive(:display_files).with("Known files for this job", ["file1.rb"])
      run
    end

    it "displays leftover files" do
      expect(TestBoosters::Shell).to receive(:display_files).with("Leftover files for this job", ["file2.rb"])
      run
    end

    it "returns the commands exit status" do
      exit_status = run

      expect(exit_status).to eq(12)
    end

    context "no files" do
      it "returns 0 exit status" do
        exit_status = described_class.run("bundle exec rspec", [], [])

        expect(exit_status).to eq(0)
      end

      it "displays no files to run" do
        expect { described_class.run("bundle exec rspec", [], []) }.to output(/No files to run in this job!/).to_stdout
      end
    end
  end
end

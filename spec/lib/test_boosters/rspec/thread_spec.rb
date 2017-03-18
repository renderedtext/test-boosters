require "spec_helper"

describe TestBoosters::Rspec::Thread do
  let(:files_from_split_configuration) {[
    "spec/a_spec.rb",
    "spec/b_spec.rb"
  ]}

  let(:leftover_files) {[
    "spec/c_spec.rb",
    "spec/d_spec.rb"
  ]}

  before do
    allow($stdout).to receive(:puts)
    allow(TestBoosters::Shell).to receive(:execute)
    allow(TestBoosters::InsightsUploader).to receive(:upload)
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
end

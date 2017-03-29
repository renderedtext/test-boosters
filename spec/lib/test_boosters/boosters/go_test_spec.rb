require "spec_helper"

describe TestBoosters::Boosters::GoTest do
  before do
    allow(TestBoosters::CliParser).to receive(:parse).and_return(:job_index => 10, :job_count => 32)
  end

  subject(:booster) { described_class.new }

  describe "#split_configuration_path" do
    before { ENV["GO_TEST_SPLIT_CONFIGURATION_PATH"] = "/tmp/path.txt" }

    context "when the GO_TEST_SPLIT_CONFIGURATION_PATH environment variable is set" do
      it "returns its values" do
        expect(booster.split_configuration_path).to eq("/tmp/path.txt")
      end
    end

    context "when the GO_TEST_SPLIT_CONFIGURATION_PATH environment variable is not set" do
      before { ENV.delete("GO_TEST_SPLIT_CONFIGURATION_PATH") }

      it "returns the path from the home directory" do
        expect(booster.split_configuration_path).to eq("#{ENV["HOME"]}/go_test_split_configuration.json")
      end
    end
  end
end

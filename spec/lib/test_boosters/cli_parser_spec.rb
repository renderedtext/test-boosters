require "spec_helper"

describe TestBoosters::CliParser do

  describe ".parse" do
    context "no command line arguments" do
      it "returns empty hash" do
        params = TestBoosters::CliParser.parse

        expect(params).to be_empty
      end
    end

    context "cli params contain the thread parameter" do
      it "recongnizes the --thread parameter" do
        ARGV = ["--thread", "12"].freeze

        params = TestBoosters::CliParser.parse

        expect(params).to eq(:index => 12)
      end
    end
  end

end

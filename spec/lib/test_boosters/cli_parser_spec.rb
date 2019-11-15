require "spec_helper"

describe TestBoosters::CliParser do

  describe ".parse" do
    context "no command line arguments" do
      before do
        ARGV = [] # rubocop:disable Style/MutableConstant
      end

      it "returns empty hash" do
        params = TestBoosters::CliParser.parse

        expect(params).to be_empty
      end
    end

    context "cli params contain the thread parameter" do
      before do
        ARGV = ["--thread", "12/32"] # rubocop:disable Style/MutableConstant
      end

      it "prints a deprecation warning" do
        deprecation = /\[DEPRECATION WARNING\] The '--thread' parameter is deprecated. Please use '--job' instead./

        expect { TestBoosters::CliParser.parse }.to output(deprecation).to_stdout
      end

      it "recongnizes the --thread parameter" do
        params = TestBoosters::CliParser.parse

        expect(params).to eq(:job_index => 12, :job_count => 32)
      end
    end

    context "cli params contain the job parameter" do
      it "recongnizes the --job parameter" do
        ARGV = ["--job", "12/32"] # rubocop:disable Style/MutableConstant

        params = TestBoosters::CliParser.parse

        expect(params).to eq(:job_index => 12, :job_count => 32)
      end
    end

    context "cli params contain the dry-run parameter" do
      it "recongnizes the --dry-run parameter" do
        ARGV = ["--dry-run"] # rubocop:disable Style/MutableConstant

        params = TestBoosters::CliParser.parse

        expect(params).to eq(:dry_run => true)
      end
    end
  end

end

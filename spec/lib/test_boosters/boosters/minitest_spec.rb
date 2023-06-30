require "spec_helper"

describe TestBoosters::Boosters::Minitest do
  before do
    allow(TestBoosters::CliParser).to receive(:parse).and_return(:job_index => 10, :job_count => 32)
  end

  subject(:booster) { described_class.new }

  describe "#split_configuration_path" do
    before { ENV["MINITEST_SPLIT_CONFIGURATION_PATH"] = "/tmp/path.txt" }

    context "when the environment variable is set" do
      it "returns its values" do
        expect(booster.split_configuration_path).to eq("/tmp/path.txt")
      end
    end

    context "when the environment variable is not set" do
      before { ENV.delete("MINITEST_SPLIT_CONFIGURATION_PATH") }

      it "returns the path from the home directory" do
        expect(booster.split_configuration_path).to eq("#{ENV["HOME"]}/minitest_split_configuration.json")
      end
    end
  end

  describe "#command" do
    before do
      ENV["MINITEST_BOOSTER_COMMAND"] = "" # reset the environment
    end

    context "when the command is passed as env var" do
      let(:command) { "bundle exec rake test" }

      it "uses that command" do
        ENV["MINITEST_BOOSTER_COMMAND"] = command

        expect(booster.command).to eq(command)
      end
    end

    context "when the command is not passed as env var, but we are in a rails env" do
      it "uses a rails specific command" do
        allow(booster).to receive(:rails_app?).and_return(true)

        expect(booster.command).to eq("bundle exec rails test")
      end
    end

    context "when there is no env command, and not in rails" do
      it "uses a 'require' command" do
        allow(booster).to receive(:rails_app?).and_return(false)

        expect(booster.command).to eq("ruby -e 'ARGV.each { |f| require \"./\#{f}\" }'")
      end
    end
  end

  describe "#file_pattern" do
    before { ENV["TEST_BOOSTERS_MINITEST_TEST_FILE_PATTERN"] = "test/system/**/*_test.rb" }

    context "when the TEST_BOOSTERS_MINITEST_TEST_FILE_PATTERN environment variable is set" do
      it "returns its values" do
        expect(booster.file_pattern).to eq("test/system/**/*_test.rb")
      end
    end

    context "when the TEST_BOOSTERS_MINITEST_TEST_FILE_PATTERN environment variable is not set" do
      before { ENV.delete("TEST_BOOSTERS_MINITEST_TEST_FILE_PATTERN") }

      it "returns the default minitest path" do
        expect(booster.file_pattern).to eq("test/**/*_test.rb")
      end
    end
  end

  describe "#exclude_pattern" do
    before do
      ENV["TEST_BOOSTERS_MINITEST_TEST_EXCLUDE_PATTERN"] =
        "test/system/**/*_test.rb"
    end

    context "when the TEST_BOOSTERS_MINITEST_TEST_EXCLUDE_PATTERN environment variable is set" do
      it "returns its values" do
        expect(booster.exclude_pattern).to eq("test/system/**/*_test.rb")
      end
    end

    context "when the TEST_BOOSTERS_MINITEST_TEST_FILE_PATTERN environment variable is not set" do
      before { ENV.delete("TEST_BOOSTERS_MINITEST_TEST_EXCLUDE_PATTERN") }

      it "returns nil" do
        expect(booster.exclude_pattern).to be_nil
      end
    end
  end
end

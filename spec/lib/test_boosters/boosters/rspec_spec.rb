require "spec_helper"

describe TestBoosters::Boosters::Rspec do
  before do
    allow(TestBoosters::CliParser).to receive(:parse).and_return(:job_index => 10, :job_count => 32)
  end

  subject(:booster) { described_class.new }

  describe "#display_header" do
    it "displays the version" do
      expect { booster.display_header }.to output(/Test Booster v#{TestBoosters::VERSION}/).to_stdout
    end

    it "displays the job index and job count" do
      expect { booster.display_header }.to output(/Job 10 out of 32/).to_stdout
    end

    it "displays the ruby version" do
      expect(TestBoosters::ProjectInfo).to receive(:display_ruby_version)

      booster.display_header
    end

    it "displays the bundler version" do
      expect(TestBoosters::ProjectInfo).to receive(:display_bundler_version)

      booster.display_header
    end

    it "displays the rspec version" do
      expect(TestBoosters::ProjectInfo).to receive(:display_rspec_version)

      booster.display_header
    end
  end

  describe "#after_job" do
    before { ENV.delete("REPORT_PATH") }

    it" uploads insights" do
      expect(TestBoosters::InsightsUploader).to receive(:upload).with("rspec", "#{ENV["HOME"]}/rspec_report.json")

      booster.after_job
    end
  end

  describe "#rspec_options" do
    context "when TB_RSPEC_FORMATTER environment variable is not set" do
      it "returns the SemaphoreFormatter with --format documentation" do
        expect(booster.rspec_options).to include("--format documentation")
      end
    end

    context "when TB_RSPEC_FORMATTER environment variable is set" do
      around do |example|
        ENV["TB_RSPEC_FORMATTER"] = "Fivemat"
        example.run
        ENV.delete("TB_RSPEC_FORMATTER")
      end

      it "returns the SemaphoreFormatter but removes --format documentation
            and uses the option specified in env variable" do
        expect(booster.rspec_options).not_to include("--format documentation")
        expect(booster.rspec_options).to include("--format Fivemat")
      end
    end
  end

  describe "#file_pattern" do
    before { ENV["TEST_BOOSTERS_RSPEC_TEST_FILE_PATTERN"] = "feature/features/**/*_spec.rb" }

    context "when the TEST_BOOSTERS_RSPEC_TEST_FILE_PATTERN environment variable is set" do
      it "returns its values" do
        expect(booster.file_pattern).to eq("feature/features/**/*_spec.rb")
      end
    end

    context "when the TEST_BOOSTERS_RSPEC_TEST_FILE_PATTERN environment variable is not set" do
      before { ENV.delete("TEST_BOOSTERS_RSPEC_TEST_FILE_PATTERN") }

      it "returns the default rspec path" do
        expect(booster.file_pattern).to eq("spec/**/*_spec.rb")
      end
    end
  end

  describe "#exclude_pattern" do
    before do
      ENV["TEST_BOOSTERS_RSPEC_TEST_EXCLUDE_PATTERN"] =
        "feature/features/**/*_spec.rb"
    end

    context "when the TEST_BOOSTERS_RSPEC_TEST_EXCLUDE_PATTERN environment variable is set" do
      it "returns its values" do
        expect(booster.exclude_pattern).to eq("feature/features/**/*_spec.rb")
      end
    end

    context "when the TEST_BOOSTERS_RSPEC_TEST_FILE_PATTERN environment variable is not set" do
      before { ENV.delete("TEST_BOOSTERS_RSPEC_TEST_EXCLUDE_PATTERN") }

      it "returns nil" do
        expect(booster.exclude_pattern).to be_nil
      end
    end
  end

  describe "#split_configuration_path" do
    before { ENV["RSPEC_SPLIT_CONFIGURATION_PATH"] = "/tmp/path.txt" }

    context "when the RSPEC_SPLIT_CONFIGURATION_PATH environment variable is set" do
      it "returns its values" do
        expect(booster.split_configuration_path).to eq("/tmp/path.txt")
      end
    end

    context "when the RSPEC_SPLIT_CONFIGURATION_PATH environment variable is not set" do
      before { ENV.delete("RSPEC_SPLIT_CONFIGURATION_PATH") }

      it "returns the path from the home directory" do
        expect(booster.split_configuration_path).to eq("#{ENV["HOME"]}/rspec_split_configuration.json")
      end
    end
  end
end

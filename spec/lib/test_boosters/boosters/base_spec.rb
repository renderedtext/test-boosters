require "spec_helper"

describe TestBoosters::Boosters::Base do
  let(:known_files) { ["file1.rb", "file2.rb"] }
  let(:leftover_files) { ["file3.rb", "file4.rb"] }

  let(:distributor) do
    instance_double(TestBoosters::Files::Distributor,
                    :files_for => [known_files, leftover_files],
                    :display_info => nil)
  end

  before do
    allow(TestBoosters::CliParser).to receive(:parse).and_return(:job_index => 10, :job_count => 32)
    allow(TestBoosters::Files::Distributor).to receive(:new).and_return(distributor)
    allow(TestBoosters::Job).to receive(:run).and_return(12)
  end

  let(:file_pattern) { "spec/**/*.rb" }
  let(:command) { "test_runner_command" }
  let(:split_configuration_path) { "/home/split_configuration.json" }

  subject(:booster) { described_class.new(file_pattern, nil, split_configuration_path, command) }

  it { expect(booster.job_index).to eq(9) }
  it { expect(booster.job_count).to eq(32) }

  describe "#distribution" do
    it "returns an instance of the file distributor" do
      expect(TestBoosters::Files::Distributor).to receive(:new).with(split_configuration_path, file_pattern, nil, 32)

      booster.distribution
    end
  end

  describe "#run" do
    it "fetches the files from the distributior" do
      expect(distributor).to receive(:files_for)

      booster.run
    end

    it "runs a job" do
      expect(TestBoosters::Job).to receive(:run).with(command, known_files, leftover_files)

      booster.run
    end

    it "returns the job's exit status" do
      expect(booster.run).to eq(12)
    end

    it "displays the version" do
      expect { booster.run }.to output(/Test Booster v#{TestBoosters::VERSION}/).to_stdout
    end

    it "displays the job index and job count" do
      expect { booster.run }.to output(/Job 10 out of 32/).to_stdout
    end

    it "calls the before job" do
      expect(booster).to receive(:before_job)

      booster.run
    end

    it "calls the after job" do
      expect(booster).to receive(:after_job)

      booster.run
    end
  end

  describe "#run with --dry-run option" do
    before do
      allow(TestBoosters::CliParser).to receive(:parse).and_return(
        :job_index => 10, :job_count => 32, :dry_run => true)
    end

    it "only prints a list of files, and doesn't run any tests" do
      expect(TestBoosters::Job).to_not receive(:run)
      booster.run
    end

    context "with no known files" do
      let(:known_files) { [] }

      it "prints the correct log messages" do
        expect(TestBoosters::Job).to_not receive(:run)
        booster.run
      end
    end

    context "with no leftover files" do
      let(:leftover_files) { [] }

      it "prints the correct log messages" do
        expect(TestBoosters::Job).to_not receive(:run)
        booster.run
      end
    end
  end
end

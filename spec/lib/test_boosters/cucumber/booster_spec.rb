require "spec_helper"

describe TestBoosters::Cucumber::Booster do

  let(:specs_path) { "/tmp/cucumber_features" }
  let(:split_configuration_path) { "/tmp/split_configuration.json" }

  before do
    FileUtils.rm_f(split_configuration_path)
    FileUtils.rm_rf(specs_path)
    FileUtils.mkdir_p(specs_path)

    ENV["SPEC_PATH"] = specs_path
    ENV["CUCUMBER_SPLIT_CONFIGURATION_PATH"] = split_configuration_path
  end

  subject(:booster) { TestBoosters::Cucumber::Booster.new(0, 3) }

  describe "#specs_path" do

    context "when the SPEC_PATH environment variable is set" do
      it "returns its values" do
        expect(booster.specs_path).to eq(specs_path)
      end
    end

    context "when the SPEC_PATH environment variable is not set" do
      before { ENV.delete("SPEC_PATH") }

      it "returns the relative 'features' folder" do
        expect(booster.specs_path).to eq("features")
      end
    end
  end

  describe "#split_configuration_path" do
    context "when the CUCUMBER_SPLIT_CONFIGURATION_PATH environment variable is set" do
      it "returns its values" do
        expect(booster.split_configuration_path).to eq(split_configuration_path)
      end
    end

    context "when the CUCUMBER_SPLIT_CONFIGURATION_PATH environment variable is not set" do
      before { ENV.delete("CUCUMBER_SPLIT_CONFIGURATION_PATH") }

      it "returns the path from the home directory" do
        expect(booster.split_configuration_path).to eq("#{ENV["HOME"]}/cucumber_split_configuration.json")
      end
    end
  end

  describe "#all_specs" do
    before do
      Support::CucumberFilesFactory.create(:path => "#{specs_path}/a.feature")
      Support::CucumberFilesFactory.create(:path => "#{specs_path}/darth_vader/c.feature")
      Support::CucumberFilesFactory.create(:path => "#{specs_path}/b.feature")
    end

    it "returns all the files" do
      expect(booster.all_specs).to eq [
        "#{specs_path}/a.feature",
        "#{specs_path}/b.feature",
        "#{specs_path}/darth_vader/c.feature"
      ]
    end
  end

  describe "#split_configuration" do
    before do
      Support::SplitConfigurationFactory.create(
        :path => split_configuration_path,
        :content => [
          { :files => ["#{specs_path}/a.feature"] },
          { :files => ["#{specs_path}/b.feature"] },
          { :files => [] }
        ])
    end

    it "returns an instance of the split configuration" do
      expect(booster.split_configuration).to be_instance_of(TestBoosters::SplitConfiguration)
    end
  end

  describe "#thread_count" do
    before do
      Support::SplitConfigurationFactory.create(
        :path => split_configuration_path,
        :content => [
          { :files => ["#{specs_path}/a.feature"] },
          { :files => ["#{specs_path}/b.feature"] },
          { :files => [] }
        ])
    end

    it "returns thread count based on the number of threads in the split configuration" do
      expect(booster.thread_count).to eq(3)
    end
  end

  describe "#all_leftover_specs" do
    context "when the split configuration has the same files as the spec directory" do
      before do
        Support::CucumberFilesFactory.create(:path => "#{specs_path}/a.feature")
        Support::CucumberFilesFactory.create(:path => "#{specs_path}/b.feature")
        Support::CucumberFilesFactory.create(:path => "#{specs_path}/darth_vader/c.feature")

        Support::SplitConfigurationFactory.create(
          :path => split_configuration_path,
          :content => [
            { :files => ["#{specs_path}/a.feature"] },
            { :files => ["#{specs_path}/b.feature"] },
            { :files => ["#{specs_path}/darth_vader/c.feature"] }
          ])
      end

      it "returns empty array" do
        expect(booster.all_leftover_specs).to eq([])
      end
    end

    context "when there are more files in the directory then in the split configuration" do
      before do
        Support::CucumberFilesFactory.create(:path => "#{specs_path}/a.feature")
        Support::CucumberFilesFactory.create(:path => "#{specs_path}/b.feature")
        Support::CucumberFilesFactory.create(:path => "#{specs_path}/darth_vader/c.feature")

        Support::SplitConfigurationFactory.create(
          :path => split_configuration_path,
          :content => [])
      end

      it "return the missing files" do
        expect(booster.all_leftover_specs).to eq([
          "#{specs_path}/a.feature",
          "#{specs_path}/b.feature",
          "#{specs_path}/darth_vader/c.feature"
        ])
      end
    end

    context "when there are more files in the split configuration then in the specs dir" do
      before do
        Support::CucumberFilesFactory.create(:path => "#{specs_path}/a.feature")

        Support::SplitConfigurationFactory.create(
          :path => split_configuration_path,
          :content => [
            { :files => ["#{specs_path}/a.feature"] },
            { :files => ["#{specs_path}/b.feature"] },
            { :files => ["#{specs_path}/darth_vader/c.feature"] }
          ])
      end

      it "returns empty array" do
        expect(booster.all_leftover_specs).to eq([])
      end
    end
  end

  describe "#threads" do
    before do
      # known files
      Support::CucumberFilesFactory.create(:path => "#{specs_path}/a.feature")
      Support::CucumberFilesFactory.create(:path => "#{specs_path}/darth_vader/c.feature")

      # unknown files
      Support::CucumberFilesFactory.create(:path => "#{specs_path}/x.feature")
      Support::CucumberFilesFactory.create(:path => "#{specs_path}/y.feature")
      Support::CucumberFilesFactory.create(:path => "#{specs_path}/palpatine/y.feature")

      Support::SplitConfigurationFactory.create(
        :path => split_configuration_path,
        :content => [
          { :files => ["#{specs_path}/a.feature"] },
          { :files => ["#{specs_path}/darth_vader/c.feature"] },
          { :files => ["#{specs_path}/b.feature"] }
        ])
    end

    it "returns 3 threads" do
      expect(booster.threads.count).to eq(3)
    end

    it "returns instances of booster threads" do
      booster.threads.each do |thread|
        expect(thread).to be_instance_of(TestBoosters::Cucumber::Thread)
      end
    end

    it "passes existing files from split configuration to threads" do
      threads = booster.threads

      expect(threads[0].files_from_split_configuration).to eq(["#{specs_path}/a.feature"])
      expect(threads[1].files_from_split_configuration).to eq(["#{specs_path}/darth_vader/c.feature"])
      expect(threads[2].files_from_split_configuration).to eq([])
    end

    it "passes leftover files to specs" do
      threads = booster.threads

      expect(threads[0].leftover_files).to eq(["#{specs_path}/y.feature"])
      expect(threads[1].leftover_files).to eq(["#{specs_path}/x.feature"])
      expect(threads[2].leftover_files).to eq(["#{specs_path}/palpatine/y.feature"])
    end
  end

  describe "#run" do
    before do
      @threads = [double, double, double]
      @booster = TestBoosters::Cucumber::Booster.new(1, 3)

      allow(@booster).to receive(:threads).and_return(@threads)
      allow(@threads[1]).to receive(:run)
    end

    it "displays title" do
      expect { @booster.run }.to output(/Cucumber Boster v#{TestBoosters::VERSION}/).to_stdout
    end

    it "invokes run on the current thread" do
      expect(@threads[1]).to receive(:run)

      @booster.run
    end

    context "split configuration is malformed" do
      before do
        allow(@booster.split_configuration).to receive(:valid?).and_return(false)
      end

      it "displays title" do
        expect { @booster.run }.to output(/Cucumber Boster v#{TestBoosters::VERSION}/).to_stdout
      end

      it "displays that the file is malformed" do
        expect { @booster.run }.to output(/\[ERROR\] The split configuration file is malformed!/).to_stdout
      end

      it "return exit status 1" do
        allow($stdout).to receive(:puts)

        expect(@booster.run).to eq(1)
      end
    end
  end

end

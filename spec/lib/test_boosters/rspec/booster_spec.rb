require "spec_helper"

describe TestBoosters::Rspec::Booster do

  let(:specs_path) { "/tmp/rspec_tests" }
  let(:split_configuration_path) { "/tmp/split_configuration.json" }

  before do
    FileUtils.rm_f(split_configuration_path)
    FileUtils.rm_rf(specs_path)
    FileUtils.mkdir_p(specs_path)

    ENV["SPEC_PATH"] = specs_path
    ENV["RSPEC_SPLIT_CONFIGURATION_PATH"] = split_configuration_path
  end

  describe "#specs_path" do
    subject(:booster) { TestBoosters::Rspec::Booster.new(0) }

    context "when the SPEC_PATH environment variable is set" do
      it "returns its values" do
        expect(booster.specs_path).to eq(specs_path)
      end
    end

    context "when the SPEC_PATH environment variable is not set" do
      before { ENV.delete("SPEC_PATH") }

      it "returns the relative 'spec' folder" do
        expect(booster.specs_path).to eq("spec")
      end
    end
  end

  describe "#split_configuration_path" do
    subject(:booster) { TestBoosters::Rspec::Booster.new(0) }

    context "when the RSPEC_SPLIT_CONFIGURATION_PATH environment variable is set" do
      it "returns its values" do
        expect(booster.split_configuration_path).to eq(split_configuration_path)
      end
    end

    context "when the RSPEC_SPLIT_CONFIGURATION_PATH environment variable is not set" do
      before { ENV.delete("RSPEC_SPLIT_CONFIGURATION_PATH") }

      it "returns the path from the home directory" do
        expect(booster.split_configuration_path).to eq("#{ENV["HOME"]}/rspec_split_configuration.json")
      end
    end
  end

  describe "#all_specs" do
    before do
      Support::RspecFilesFactory.create(:path => "#{specs_path}/a_spec.rb")
      Support::RspecFilesFactory.create(:path => "#{specs_path}/lib/darth_vader/c_spec.rb")
      Support::RspecFilesFactory.create(:path => "#{specs_path}/b_spec.rb")
    end

    subject(:booster) { TestBoosters::Rspec::Booster.new(0) }

    it "returns all the files" do
      expect(booster.all_specs).to eq [
        "#{specs_path}/a_spec.rb",
        "#{specs_path}/b_spec.rb",
        "#{specs_path}/lib/darth_vader/c_spec.rb"
      ]
    end
  end

end

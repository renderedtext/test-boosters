require "spec_helper"

describe TestBoosters::Rspec::Booster do

  let(:specs_path) { "/tmp/rspec_tests" }

  before do
    FileUtils.rm_rf(specs_path)
    FileUtils.mkdir_p(specs_path)

    ENV["SPEC_PATH"] = specs_path
  end

  describe "#specs_path" do
    subject(:booster) { TestBoosters::Rspec::Booster.new(0) }

    context "when the SPEC_PATH environment variable is set" do
      it "returns its values" do
        expect(booster.specs_path).to eq(specs_path)
      end
    end

    context "when the SPEC_PATH environment is not set" do
      before { ENV.delete("SPEC_PATH") }

      it "returns the relative 'spec' folder" do
        expect(booster.specs_path).to eq("spec")
      end
    end
  end

end

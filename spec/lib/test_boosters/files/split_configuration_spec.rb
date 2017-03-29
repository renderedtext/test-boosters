require "spec_helper"

describe TestBoosters::Files::SplitConfiguration do

  context "file does not exists" do
    subject(:configuration) { described_class.new("/tmp/non_existing_file_path") }

    it { is_expected.not_to be_present }
    it { is_expected.to be_valid }

    describe "#all_files" do
      it "is an empty array" do
        expect(configuration.all_files).to eq([])
      end
    end

    describe "#files_for_job" do
      it "is an empty array" do
        expect(configuration.files_for_job(10)).to eq([])
      end
    end
  end

  context "file is not parsable" do
    before do
      @path = "/tmp/split_configuration"

      File.write(@path, "try to parse me :)")
    end

    subject(:configuration) { described_class.new(@path) }

    it { is_expected.to be_present }
    it { is_expected.not_to be_valid }

    describe "#all_files" do
      it "is an empty array" do
        expect(configuration.all_files).to eq([])
      end
    end

    describe "#files_for_job" do
      it "is an empty array" do
        expect(configuration.files_for_job(10)).to eq([])
      end
    end
  end

  context "file is parsable, but contains invalid structure" do
    before do
      content = [{ :parse => :me }]

      @path = "/tmp/split_configuration"

      File.write(@path, content.to_json)
    end

    subject(:configuration) { described_class.new(@path) }

    it { is_expected.to be_present }
    it { is_expected.to_not be_valid }

    describe "#all_files" do
      it "is an empty array" do
        expect(configuration.all_files).to eq([])
      end
    end

    describe "#files_for_job" do
      it "is an empty array" do
        expect(configuration.files_for_job(10)).to eq([])
      end
    end
  end

  context "file is present on the disk" do
    before do
      content = [
        { :files => ["a_spec.rb", "d_spec.rb", "c_spec.rb"] },
        { :files => ["f_spec.rb", "b_spec.rb"] },
        { :files => [] }
      ]

      @path = "/tmp/split_configuration"

      File.write(@path, content.to_json)
    end

    subject(:configuration) { described_class.new(@path) }

    it { is_expected.to be_present }

    describe "#all_files" do
      it "returns all files from the split configuration" do
        expect(configuration.all_files).to eq([
          "a_spec.rb",
          "b_spec.rb",
          "c_spec.rb",
          "d_spec.rb",
          "f_spec.rb"
        ])
      end
    end

    describe "#jobs" do
      it "returns instances of TestBoosters::SplitConfiguration::Job" do
        configuration.jobs.each do |job|
          expect(job).to be_instance_of(TestBoosters::Files::SplitConfiguration::Job)
        end
      end

      it "puts every file to its proper job instance" do
        expect(configuration.jobs[0].files).to eq ["a_spec.rb", "c_spec.rb", "d_spec.rb"]
        expect(configuration.jobs[1].files).to eq ["b_spec.rb", "f_spec.rb"]
        expect(configuration.jobs[2].files).to eq []
      end
    end
  end

end

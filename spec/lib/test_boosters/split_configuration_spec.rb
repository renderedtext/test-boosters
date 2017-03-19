require "spec_helper"

describe TestBoosters::SplitConfiguration do

  context "file does not exists" do
    subject(:configuration) { TestBoosters::SplitConfiguration.new("/tmp/non_existing_file_path") }

    it { is_expected.not_to be_present }

    describe "#all_files" do
      it "is an empty array" do
        expect(configuration.all_files).to eq([])
      end
    end

    describe "#threads" do
      it "is an empty array" do
        expect(configuration.threads).to eq([])
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

    subject(:configuration) { TestBoosters::SplitConfiguration.new(@path) }

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

    describe "#threads" do
      it "returns instances of TestBoosters::SplitConfiguration::Thread" do
        configuration.threads.each do |thread|
          expect(thread).to be_instance_of(TestBoosters::SplitConfiguration::Thread)
        end
      end

      it "puts every file to its proper thread instance" do
        expect(configuration.threads[0].files).to eq ["a_spec.rb", "c_spec.rb", "d_spec.rb"]
        expect(configuration.threads[1].files).to eq ["b_spec.rb", "f_spec.rb"]
        expect(configuration.threads[2].files).to eq []
      end
    end
  end

end

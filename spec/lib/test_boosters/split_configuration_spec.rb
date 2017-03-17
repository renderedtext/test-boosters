require "spec_helper"

describe TestBoosters::SplitConfiguration do

  describe ".for_rspec" do
    context "env var points to file location" do
      before do
        content = [ { :files => ["dragon_ball_z_spec.rb"] } ]

        @path = "/tmp/split_configuration"

        ENV["RSPEC_SPLIT_CONFIGURATION_PATH"] = @path

        File.write(@path, content.to_json)
      end

      subject { TestBoosters::SplitConfiguration.new(@path) }

      it "loads from the file pointed by the env var" do
        expect(subject.all_files).to include("dragon_ball_z_spec.rb")
      end
    end
  end

  context "file does not exists" do
    subject { TestBoosters::SplitConfiguration.new("/tmp/non_existing_file_path") }

    it { is_expected.to_not be_present }

    describe "#all_files" do
      it "should be an empty array" do
        expect(subject.all_files).to eq([])
      end
    end

    describe "#threads" do
      it "should be an empty array" do
        expect(subject.threads).to eq([])
      end
    end
  end

  context "file is present on the disk" do
    before do
      content = [
        { :files => ["a_spec.rb", "d_spec.rb", "c_spec.rb"] },
        { :files => ["f_spec.rb", "b_spec.rb"] },
        { :files => [] },
      ]

      @path = "/tmp/split_configuration"

      File.write(@path, content.to_json)
    end

    subject { TestBoosters::SplitConfiguration.new(@path) }

    it { is_expected.to be_present }

    describe "#all_files" do
      it "should return all files from the split configuration" do
        expect(subject.all_files).to eq([
          "a_spec.rb",
          "b_spec.rb",
          "c_spec.rb",
          "d_spec.rb",
          "f_spec.rb",
        ])
      end
    end

    describe "#threads" do
      it "returns instances of TestBoosters::SplitConfiguration::Thread" do
        subject.threads.each do |thread|
          expect(thread).to be_instance_of(TestBoosters::SplitConfiguration::Thread)
        end
      end

      it "puts every file to its proper thread instance" do
        expect(subject.threads[0].files).to eq ["a_spec.rb", "c_spec.rb", "d_spec.rb"]
        expect(subject.threads[1].files).to eq ["b_spec.rb", "f_spec.rb"]
        expect(subject.threads[2].files).to eq []
      end
    end
  end

end

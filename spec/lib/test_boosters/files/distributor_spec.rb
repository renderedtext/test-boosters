require "spec_helper"

describe TestBoosters::Files::Distributor do
  before do
    @base_path = "/tmp/#{SecureRandom.uuid}"

    FileUtils.rm_rf(@base_path)

    Support::RspecFilesFactory.create(:path => "#{@base_path}/spec/a_spec.rb")
    Support::RspecFilesFactory.create(:path => "#{@base_path}/spec/lib/b_spec.rb")
    Support::RspecFilesFactory.create(:path => "#{@base_path}/spec/c_spec.rb")

    @split_configuration_path = "/tmp/conf.json"

    Support::SplitConfigurationFactory.create(:path => @split_configuration_path, :content => [
      { :files => ["#{@base_path}/spec/a_spec.rb"] }
    ])

    @file_pattern = "#{@base_path}/spec/**/*_spec.rb"
    @exclude_pattern = nil
  end

  subject(:distributor) { described_class.new(@split_configuration_path, @file_pattern, @exclude_pattern, 10) }

  describe "#all_files" do
    it "returns all files that match the pattern" do
      expect(distributor.all_files).to eq([
        "#{@base_path}/spec/a_spec.rb",
        "#{@base_path}/spec/lib/b_spec.rb",
        "#{@base_path}/spec/c_spec.rb"
      ].sort)
    end
  end

  describe "#files_for" do
    it "lists all files that match the pattern but are not in the split conf" do
      known, leftover = distributor.files_for(0)

      expect(known).to eq(["#{@base_path}/spec/a_spec.rb"])
      expect(leftover).to eq(["#{@base_path}/spec/c_spec.rb"])
    end
  end

  describe "#display_info" do
    subject do
      -> { distributor.display_info }
    end

    it { is_expected.to output(/Split configuration present: yes/).to_stdout }
    it { is_expected.to output(/Split configuration valid: yes/).to_stdout }
    it { is_expected.to output(/Split configuration file count: 1/).to_stdout }
  end

  context "with exclude pattern" do
    before do
      @exclude_pattern = "#{@base_path}/spec/**/c_spec*"
    end

    describe "#all_files" do
      it "returns all files that match the pattern, but don't match the exclude pattern" do
        expect(distributor.all_files).to eq([
          "#{@base_path}/spec/a_spec.rb",
          "#{@base_path}/spec/lib/b_spec.rb"
        ].sort)
      end
    end

    describe "#files_for" do
      it "lists all files that match the pattern but are not in the split conf" do
        known, leftover = distributor.files_for(0)

        expect(known).to eq(["#{@base_path}/spec/a_spec.rb"])
        expect(leftover).to eq(["#{@base_path}/spec/lib/b_spec.rb"])
      end
    end

    describe "#display_info" do
      subject do
        -> { distributor.display_info }
      end

      it { is_expected.to output(/Split configuration present: yes/).to_stdout }
      it { is_expected.to output(/Split configuration valid: yes/).to_stdout }
      it { is_expected.to output(/Split configuration file count: 1/).to_stdout }
    end
  end
end

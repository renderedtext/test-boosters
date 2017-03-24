require "spec_helper"

describe TestBoosters::ProjectInfo do

  describe ".display_ruby_version" do
    it "displays ruby version" do
      expect { described_class.display_ruby_version }.to output(/Ruby Version: 2/).to_stdout
    end
  end

  describe ".display_bundler_version" do
    it "displays bundler version" do
      expect { described_class.display_bundler_version }.to output(/Bundler Version: 1/).to_stdout
    end
  end

  describe ".display_rspec_version" do
    it "displays rspec version" do
      expect { described_class.display_rspec_version }.to output(/RSpec Version: 3/).to_stdout
    end
  end

  describe ".display_cucumber_version" do
    it "displays cucumber version" do
      expect { described_class.display_cucumber_version }.to output(/Cucumber Version: 2/).to_stdout
    end
  end

  describe ".display_split_configuration_info" do
    let(:files) { ["file1", "file2", "file3" ] }
    let(:split_conf) { double(TestBoosters::SplitConfiguration, :all_files => files, :present? => true, :valid? => false) }

    it "displays its presence" do
      expect { described_class.display_split_configuration_info(split_conf) }.to output(/Split configuration present: yes/).to_stdout
    end

    it "displays its validity" do
      expect { described_class.display_split_configuration_info(split_conf) }.to output(/Split configuration valid: no/).to_stdout
    end

    it "displays its file count" do
      expect { described_class.display_split_configuration_info(split_conf) }.to output(/Split configuration file count: 3/).to_stdout
    end
  end

end

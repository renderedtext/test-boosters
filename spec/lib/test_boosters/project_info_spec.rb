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
      expect { described_class.display_rspec_version }.to output(/RSpec Version: .*3/).to_stdout
    end
  end

  describe ".display_cucumber_version" do
    it "displays cucumber version" do
      expect { described_class.display_cucumber_version }.to output(/Cucumber Version: not found/).to_stdout
    end
  end

end

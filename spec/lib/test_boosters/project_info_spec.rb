require "spec_helper"

describe TestBoosters::ProjectInfo do

  describe ".display_ruby_version" do
    it "displays ruby version" do
      expect { described_class.display_ruby_version }.to output(/Ruby Version: \d/).to_stdout
    end
  end

  describe ".display_bundler_version" do
    it "displays bundler version" do
      expect { described_class.display_bundler_version }.to output(/Bundler Version: \d/).to_stdout
    end
  end

  describe ".display_rspec_version" do
    it "displays rspec version" do
      expect { described_class.display_rspec_version }.to output(/RSpec Version: .*3/).to_stdout
    end

    it "probes rspec-core through the active bundle and prints the result" do
      allow(TestBoosters::Shell).to receive(:evaluate).and_return("RSpec 3.13.6")

      expect { described_class.display_rspec_version }.to output("RSpec Version: RSpec 3.13.6\n").to_stdout
      expect(TestBoosters::Shell).to have_received(:evaluate)
        .with(a_string_including("bundle exec ruby", 'find_all_by_name("rspec-core")'))
    end

    it "prints whatever the probe returns (e.g. not found)" do
      allow(TestBoosters::Shell).to receive(:evaluate).and_return("not found")

      expect { described_class.display_rspec_version }.to output("RSpec Version: not found\n").to_stdout
    end
  end

  describe ".display_cucumber_version" do
    it "displays cucumber version" do
      expect { described_class.display_cucumber_version }.to output(/Cucumber Version: not found/).to_stdout
    end

    it "probes cucumber through the active bundle and prints the result" do
      allow(TestBoosters::Shell).to receive(:evaluate).and_return("3.2.0")

      expect { described_class.display_cucumber_version }.to output("Cucumber Version: 3.2.0\n").to_stdout
      expect(TestBoosters::Shell).to have_received(:evaluate)
        .with(a_string_including("bundle exec ruby", 'find_all_by_name("cucumber")'))
    end
  end

end

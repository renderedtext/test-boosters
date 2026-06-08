require "spec_helper"

describe TestBoosters::Logger do

  before do
    @log_path = "/tmp/logger_spec_#{SecureRandom.uuid}.log"

    @previous_log_path = ENV["ERROR_LOG_PATH"]
    ENV["ERROR_LOG_PATH"] = @log_path
  end

  after do
    # Restore whatever was set before (don't clobber an externally provided value).
    if @previous_log_path.nil?
      ENV.delete("ERROR_LOG_PATH")
    else
      ENV["ERROR_LOG_PATH"] = @previous_log_path
    end

    File.delete(@log_path) if File.exist?(@log_path)
  end

  describe ".info" do
    it "appends the message to the log file" do
      described_class.info("hello")

      expect(File.read(@log_path)).to eq("hello\n")
    end
  end

  describe ".error" do
    it "appends the message to the log file" do
      described_class.error("boom")

      expect(File.read(@log_path)).to eq("boom\n")
    end

    it "preserves existing messages" do
      described_class.error("first")
      described_class.error("second")

      expect(File.read(@log_path)).to eq("first\nsecond\n")
    end
  end

  describe "default log path" do
    it "writes under $HOME/test_booster_error.log when ERROR_LOG_PATH is not set" do
      require "tmpdir"

      original_home = ENV["HOME"]
      ENV.delete("ERROR_LOG_PATH")

      # Classic begin/ensure (not a do...end ensure) so the pinned RuboCop's
      # parser 2.4 can lint this file on Ruby 2.6.
      begin
        Dir.mktmpdir do |home|
          ENV["HOME"] = home

          described_class.info("default-path")

          expect(File.read(File.join(home, "test_booster_error.log"))).to eq("default-path\n")
        end
      ensure
        ENV["HOME"] = original_home
      end
    end
  end

end

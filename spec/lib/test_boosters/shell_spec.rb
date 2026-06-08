require "spec_helper"

describe TestBoosters::Shell do

  describe ".execute" do
    it "returns the exit status of the command" do
      result = described_class.execute("false")

      expect(result).to eq(1)
    end

    it "displays the executed command" do
      expect { described_class.execute("echo 'here'") }.to output(/echo 'here'/).to_stdout
    end

    it "displays the output of the command" do
      expect { described_class.execute("echo 'yo'") }.to output(/yo/).to_stdout_from_any_process
    end

    it "runs the command inside with_clean_env" do
      # `execute` shells out to the user's real test command, so it must run in a
      # clean Bundler env (unlike `evaluate`). Pin that so the isolation isn't lost.
      expect(described_class).to receive(:with_clean_env).and_call_original

      described_class.execute("true", :silent => true)
    end

    describe "silent execution" do
      it "doesn't display the command on stdout" do
        expect { described_class.execute("echo 'here'", :silent => true) }.to_not output(/echo 'here'/).to_stdout
      end

      it "displays the output of the command" do
        expect { described_class.execute("echo 'yo'", :silent => true) }.to output(/yo/).to_stdout_from_any_process
      end
    end
  end

  describe ".evaluate" do
    it "returns the standard output of the command" do
      expect(described_class.evaluate("echo hello")).to eq("hello\n")
    end

    it "does not wrap the command in with_clean_env" do
      # Deliberate asymmetry with `execute`: version probes want the project's
      # active bundle, so `evaluate` must NOT strip the Bundler env.
      expect(described_class).not_to receive(:with_clean_env)

      described_class.evaluate("true")
    end
  end

  describe ".with_clean_env" do
    it "returns the value produced by the block" do
      hide_const("Bundler")

      expect(described_class.with_clean_env { 42 }).to eq(42)
    end

    it "yields directly when Bundler is not defined" do
      hide_const("Bundler")

      expect { |probe| described_class.with_clean_env(&probe) }.to yield_control
    end

    it "uses Bundler.with_unbundled_env when it is available" do
      fake_bundler = double("Bundler") # rubocop:disable RSpec/VerifiedDoubles
      stub_const("Bundler", fake_bundler)

      expect(fake_bundler).to receive(:with_unbundled_env).and_yield

      expect { |probe| described_class.with_clean_env(&probe) }.to yield_control
    end

    it "falls back to Bundler.with_clean_env on Bundler versions without with_unbundled_env" do
      fake_bundler = double("Bundler") # rubocop:disable RSpec/VerifiedDoubles
      stub_const("Bundler", fake_bundler)

      # Only the legacy method is stubbed, so respond_to?(:with_unbundled_env) is false.
      expect(fake_bundler).to receive(:with_clean_env).and_yield

      expect { |probe| described_class.with_clean_env(&probe) }.to yield_control
    end
  end

  describe ".display_files" do
    it "displays the file count" do
      expect { described_class.display_files("files", ["file1", "file2"]) }.to output(/2/).to_stdout
    end
  end

end

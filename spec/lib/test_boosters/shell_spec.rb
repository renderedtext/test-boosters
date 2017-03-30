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

    describe "silent execution" do
      it "doesn't display the command on stdout" do
        expect { described_class.execute("echo 'here'", :silent => true) }.to_not output(/echo 'here'/).to_stdout
      end

      it "displays the output of the command" do
        expect { described_class.execute("echo 'yo'", :silent => true) }.to output(/yo/).to_stdout_from_any_process
      end
    end
  end

  describe ".display_files" do
    it "displays the file count" do
      expect { described_class.display_files("files", ["file1", "file2"]) }.to output(/2/).to_stdout
    end
  end

end

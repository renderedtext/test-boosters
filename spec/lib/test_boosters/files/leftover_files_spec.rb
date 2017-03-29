require "spec_helper"
require "tempfile"

describe TestBoosters::Files::LeftoverFiles do

  def create_leftover_file(options = {})
    bytes = options.fetch(:bytes)

    file = Tempfile.new("file-size-#{bytes}-bytes")

    # construct fake file size
    file.write("a" * bytes)
    file.close

    file.path
  end

  describe "#select" do

    context "there are no leftover files" do
      subject(:leftover) { described_class.new([]) }

      it { expect(leftover.select(:index => 0, :total => 3)).to eq([]) }
      it { expect(leftover.select(:index => 1, :total => 3)).to eq([]) }
      it { expect(leftover.select(:index => 2, :total => 3)).to eq([]) }
    end

    context "there is only one leftover file" do
      before do
        @files = [create_leftover_file(:bytes => 10)]
      end

      subject(:leftover) { described_class.new(@files) }

      it { expect(leftover.select(:index => 0, :total => 3)).to eq([@files[0]]) }
      it { expect(leftover.select(:index => 1, :total => 3)).to eq([]) }
      it { expect(leftover.select(:index => 2, :total => 3)).to eq([]) }
    end

    context "there is just as much leftover files as jobs" do
      before do
        @files = [
          create_leftover_file(:bytes => 20),
          create_leftover_file(:bytes => 10),
          create_leftover_file(:bytes => 30)
        ]
      end

      subject(:leftover) { described_class.new(@files) }

      it { expect(leftover.select(:index => 0, :total => 3)).to eq([@files[2]]) }
      it { expect(leftover.select(:index => 1, :total => 3)).to eq([@files[0]]) }
      it { expect(leftover.select(:index => 2, :total => 3)).to eq([@files[1]]) }
    end

    context "there is more leftover files than jobs" do
      before do
        @files = [
          create_leftover_file(:bytes => 20),
          create_leftover_file(:bytes => 10),
          create_leftover_file(:bytes => 30)
        ]
      end

      subject(:leftover) { described_class.new(@files) }

      it { expect(leftover.select(:index => 0, :total => 2)).to eq([@files[2], @files[1]]) }
      it { expect(leftover.select(:index => 1, :total => 2)).to eq([@files[0]]) }
    end
  end
end

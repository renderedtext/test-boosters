require "spec_helper"

describe TestBoosters::LeftoverFiles do
  describe "#select" do

    context "there are no leftover files" do
      subject(:leftover) { TestBoosters::LeftoverFiles.new([]) }

      it { expect(leftover.select(:index => 0, :total => 3)).to eq([]) }
      it { expect(leftover.select(:index => 1, :total => 3)).to eq([]) }
      it { expect(leftover.select(:index => 2, :total => 3)).to eq([]) }
    end

    context "there is only one leftover file" do
      subject(:leftover) { TestBoosters::LeftoverFiles.new([a]) }

      it { expect(leftover.select(:index => 0, :total => 3)).to eq([a]) }
      it { expect(leftover.select(:index => 1, :total => 3)).to eq([]) }
      it { expect(leftover.select(:index => 2, :total => 3)).to eq([]) }
    end

    context "there is just as much leftover files as threads" do
      subject(:leftover) { TestBoosters::LeftoverFiles.new([a, b, c]) }

      it { expect(leftover.select(:index => 0, :total => 3)).to eq([a]) }
      it { expect(leftover.select(:index => 1, :total => 3)).to eq([c]) }
      it { expect(leftover.select(:index => 2, :total => 3)).to eq([b]) }
    end

    context "there is more leftover files than threads" do
      subject(:leftover) { TestBoosters::LeftoverFiles.new([a, b, c]) }

      it { expect(leftover.select(:index => 0, :total => 2)).to eq([a, b]) }
      it { expect(leftover.select(:index => 1, :total => 2)).to eq([c]) }
    end

  end

  def a
    Setup.a
  end

  def b
    Setup.b
  end

  def c
    Setup.c
  end

end

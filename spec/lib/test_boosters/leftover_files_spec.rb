require "spec_helper"

describe TestBoosters::LeftoverFiles do
  describe "#select" do
    it "no leftover specs" do
      expect(TestBoosters::LeftoverFiles.new([]).select(:index => 0, :total => 3)).to eq([])
    end

    it "1 leftover spec, 3 threads, index 0" do
      expect(TestBoosters::LeftoverFiles.new([a]).select(:index => 0, :total => 3)).to eq([a])
    end

    it "1 leftover spec, 3 threads, index 2" do
      expect(TestBoosters::LeftoverFiles.new([a]).select(:index => 2, :total => 3)).to eq([])
    end

    it "3 leftover specs, 2 threads, index 0" do
      input = input_specs
      expected = [a, b]
      expect(TestBoosters::LeftoverFiles.new(input).select(:index => 0, :total => 2)).to eq(expected)
    end

    it "3 leftover specs, 2 threads, index 1" do
      input = input_specs
      expected = [c]

      expect(TestBoosters::LeftoverFiles.new(input).select(:index => 1, :total => 2)).to eq(expected)
    end

    it "3 leftover specs, 3 threads, index 0" do
      input = input_specs
      expected = [a]
      expect(TestBoosters::LeftoverFiles.new(input).select(:index => 0, :total => 3)).to eq(expected)
    end

    it "3 leftover specs, 3 threads, index 2" do
      input = input_specs
      expected = [b]
      expect(TestBoosters::LeftoverFiles.new(input).select(:index => 2, :total => 3)).to eq(expected)
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

  def input_specs
    Setup.input_specs
  end

  def expected_specs
    Setup.expected_specs
  end

end

require 'spec_helper'

describe LeftoverFiles do
  context "test file sorting" do
    it "tests for empty array" do
      expect(LeftoverFiles.sort_by_size([])).to eq([])
    end

    it "tests single element array" do
      expect(LeftoverFiles.sort_by_size([a])).to eq([a])
    end

    it "tests for non-existent file in array" do
      expect(LeftoverFiles.sort_by_size(["non-existent"])).to eq([])
    end

    it "tests regular input" do
      input    = input_specs
      expected = expected_specs
      expect(LeftoverFiles.sort_by_size(input)).to eq(expected)
    end

    it "tests regular input with non-existent files" do
      input    = input_specs + ["non-existent"]
      expected = expected_specs
      expect(LeftoverFiles.sort_by_size(input)).to eq(expected)
    end
  end

  context "test select_leftover_specs()" do
    it "no leftover specs" do
      expect(LeftoverFiles.select([], 3, 0)).to eq([])
    end

    it "1 leftover spec, 3 threads, index 0" do
      expect(LeftoverFiles.select([a], 3, 0)).to eq([a])
    end

    it "1 leftover spec, 3 threads, index 2" do
      expect(LeftoverFiles.select([a], 3, 2)).to eq([])
    end

    it "3 leftover specs, 2 threads, index 0" do
      input    = input_specs
      expected = [a, b]
      expect(LeftoverFiles.select(input, 2, 0)).to eq(expected)
    end

    it "3 leftover specs, 2 threads, index 1" do
      input    = input_specs
      expected = [c]
      expect(LeftoverFiles.select(input, 2, 1)).to eq(expected)
    end

    it "3 leftover specs, 3 threads, index 0" do
      input    = input_specs
      expected = [a]
      expect(LeftoverFiles.select(input, 3, 0)).to eq(expected)
    end

    it "3 leftover specs, 3 threads, index 2" do
      input    = input_specs
      expected = [b]
      expect(LeftoverFiles.select(input, 3, 2)).to eq(expected)
    end
  end

  def a() Setup.a end
  def b() Setup.b end
  def c() Setup.c end

  def input_specs() Setup.input_specs  end

  def expected_specs()  Setup.expected_specs  end
end

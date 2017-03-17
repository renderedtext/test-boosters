require "spec_helper"

describe TestBoosters::LeftoverFiles do
  describe ".sort_descending_by_size" do
    context "empty array" do
      it "returns an empty array" do
        expect(TestBoosters::LeftoverFiles.sort_descending_by_size([])).to eq([])
      end
    end

    context "single element in the array" do
      it "returns an array with one element" do
        expect(TestBoosters::LeftoverFiles.sort_descending_by_size([a])).to eq([a])
      end
    end

    context "non-existing file in the files array" do
      it "returns an empty array" do
        expect(TestBoosters::LeftoverFiles.sort_descending_by_size(["non-existent"])).to eq([])
      end
    end

    context "regular input" do
      it "returns the spec list sorted by size" do
        input = input_specs
        expected = expected_specs

        expect(TestBoosters::LeftoverFiles.sort_descending_by_size(input)).to eq(expected)
      end
    end

    context "regular input with non existing files" do
      it "returns a spec list sorted by size and filters out non existing files" do
        input = input_specs + ["non-existent"]
        expected = expected_specs

        expect(TestBoosters::LeftoverFiles.sort_descending_by_size(input)).to eq(expected)
      end
    end
  end

  context "test select_leftover_specs()" do
    it "no leftover specs" do
      expect(TestBoosters::LeftoverFiles.select([], 3, 0)).to eq([])
    end

    it "1 leftover spec, 3 threads, index 0" do
      expect(TestBoosters::LeftoverFiles.select([a], 3, 0)).to eq([a])
    end

    it "1 leftover spec, 3 threads, index 2" do
      expect(TestBoosters::LeftoverFiles.select([a], 3, 2)).to eq([])
    end

    it "3 leftover specs, 2 threads, index 0" do
      input    = input_specs
      expected = [a, b]
      expect(TestBoosters::LeftoverFiles.select(input, 2, 0)).to eq(expected)
    end

    it "3 leftover specs, 2 threads, index 1" do
      input    = input_specs
      expected = [c]
      expect(TestBoosters::LeftoverFiles.select(input, 2, 1)).to eq(expected)
    end

    it "3 leftover specs, 3 threads, index 0" do
      input    = input_specs
      expected = [a]
      expect(TestBoosters::LeftoverFiles.select(input, 3, 0)).to eq(expected)
    end

    it "3 leftover specs, 3 threads, index 2" do
      input    = input_specs
      expected = [b]
      expect(TestBoosters::LeftoverFiles.select(input, 3, 2)).to eq(expected)
    end
  end

  def a() Setup.a end
  def b() Setup.b end
  def c() Setup.c end

  def input_specs() Setup.input_specs  end

  def expected_specs()  Setup.expected_specs  end
end

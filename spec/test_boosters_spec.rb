require 'spec_helper'

Booster = Semaphore::RspecBooster

describe TestBoosters do
  it 'has a version number' do
    expect(TestBoosters::VERSION).not_to be nil
  end

  context "test file sorting" do
    it "tests for empty array" do
      expect(LeftoverSpecs.sort_by_size([])).to eq([])
    end

    it "tests single element array" do
      expect(LeftoverSpecs.sort_by_size([a])).to eq([a])
    end

    it "tests for non-existent file in array" do
      expect(LeftoverSpecs.sort_by_size(["non-existent"])).to eq([])
    end

    it "tests regular input" do
      input    = input_specs
      expected = expected_specs
      expect(LeftoverSpecs.sort_by_size(input)).to eq(expected)
    end

    it "tests regular input with non-existent files" do
      input    = input_specs
      expected = expected_specs
      expect(LeftoverSpecs.sort_by_size(input)).to eq(expected)
    end
  end

  context "test select_leftover_specs()" do
    before(:context) do
      @booster = Booster.new(0)
    end

    it "no leftover specs" do
      expect(LeftoverSpecs.select([], 3, 0)).to eq([])
    end

    it "1 leftover spec, 3 threads, index 0" do
      expect(LeftoverSpecs.select([a], 3, 0)).to eq([a])
    end

    it "1 leftover spec, 3 threads, index 2" do
      booster = Booster.new(2)
      expect(LeftoverSpecs.select([a], 3, 2)).to eq([])
    end

    it "3 leftover specs, 2 threads, index 0" do
      input    = input_specs
      expected = [a, b]
      expect(LeftoverSpecs.select(input, 2, 0)).to eq(expected)
    end

    it "3 leftover specs, 2 threads, index 1" do
      input    = input_specs
      expected = [c]
      booster = Booster.new(1)
      expect(LeftoverSpecs.select(input, 2, 1)).to eq(expected)
    end

    it "3 leftover specs, 3 threads, index 0" do
      input    = input_specs
      expected = [a]
      expect(LeftoverSpecs.select(input, 3, 0)).to eq(expected)
    end

    it "3 leftover specs, 3 threads, index 2" do
      input    = input_specs
      expected = [b]
      expect(LeftoverSpecs.select(input, 3, 2)).to eq(expected)
    end
  end

  context "test select()" do
    before(:context) do
      @report_file = "/tmp/rspec_report.json"
      ENV["REPORT_PATH"] = @report_file
      ENV["SPEC_PATH"]   = "test_data"
    end

    it "2 threads running in thread 1, no scheduled specs, 3 leftover specs" do
      expected = [a, b]
      write_report_file('[{"files": []}, {"files": []}]')

      expect(Booster.new(0).select).to eq(expected)
    end

    it "2 threads running in thread 2, no scheduled specs, 3 leftover specs" do
      expected = [c]
      write_report_file('[{"files": []}, {"files": []}]')

      expect(Booster.new(1).select).to eq(expected)
    end

    it "4 threads running in thread 4, no scheduled specs, 3 leftover specs" do
      expected = []
      write_report_file('[{"files": []}, {"files": []}, {"files": []}, {"files": []}]')

      expect(Booster.new(3).select).to eq(expected)
    end

    it "4 threads, running in thread 1, no scheduled specs, 3 leftover specs" do
      expected = Booster::Error
      write_report_file('{"malformed": []}')

      expect(Booster.new(0).select).to eq(expected)
    end

    def write_report_file(report)
      File.write(@report_file, report)
    end
  end

  def a() "test_data/a_spec.rb" end
  def b() "test_data/b_spec.rb" end
  def c() "test_data/c_spec.rb" end

  def input_specs()     [a, b, c]  end

  def expected_specs()  [a, c, b]  end
end

require 'spec_helper'

describe TestBoosters do
  it 'has a version number' do
    expect(TestBoosters::VERSION).not_to be nil
  end

  context "test file sorting" do
    before(:context) do
      @booster = RspecBooster.new(0)
    end

    it "tests for empty array" do
      expect(@booster.sort_by_size([])).to eq([])
    end

    it "tests single element array" do
      expect(@booster.sort_by_size([a])).to eq([a])
    end

    it "tests for non-existent file in array" do
      expect(@booster.sort_by_size(["non-existent"])).to eq([])
    end

    it "tests regular input" do
      input    = input_specs
      expected = expected_specs
      expect(@booster.sort_by_size(input)).to eq(expected)
    end

    it "tests regular input with non-existent files" do
      input    = input_specs
      expected = expected_specs
      expect(@booster.sort_by_size(input)).to eq(expected)
    end
  end

  context "test select_leftover_specs()" do
    before(:context) do
      @booster = RspecBooster.new(0)
    end

    it "no leftover specs" do
      expect(@booster.select_leftover_specs([], 3)).to eq([])
    end

    it "1 leftover spec, 3 threads, index 0" do
      expect(@booster.select_leftover_specs([a], 3)).to eq([a])
    end

    it "1 leftover spec, 3 threads, index 2" do
      booster = RspecBooster.new(2)
      expect(booster.select_leftover_specs([a], 3)).to eq([])
    end

    it "3 leftover specs, 2 threads, index 0" do
      input    = input_specs
      expected = [a, b]
      expect(@booster.select_leftover_specs(input, 2)).to eq(expected)
    end

    it "3 leftover specs, 2 threads, index 1" do
      input    = input_specs
      expected = [c]
      booster = RspecBooster.new(1)
      expect(booster.select_leftover_specs(input, 2)).to eq(expected)
    end

    it "3 leftover specs, 3 threads, index 0" do
      input    = input_specs
      expected = [a]
      expect(@booster.select_leftover_specs(input, 3)).to eq(expected)
    end

    it "3 leftover specs, 3 threads, index 2" do
      input    = input_specs
      expected = [b]
      booster = RspecBooster.new(2)
      expect(booster.select_leftover_specs(input, 3)).to eq(expected)
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

      expect(RspecBooster.new(0).select).to eq(expected)
    end

    it "2 threads running in thread 2, no scheduled specs, 3 leftover specs" do
      expected = [c]
      write_report_file('[{"files": []}, {"files": []}]')

      expect(RspecBooster.new(1).select).to eq(expected)
    end

    it "4 threads running in thread 4, no scheduled specs, 3 leftover specs" do
      expected = []
      write_report_file('[{"files": []}, {"files": []}, {"files": []}, {"files": []}]')

      expect(RspecBooster.new(3).select).to eq(expected)
    end

    it "4 threads, running in thread 1, no scheduled specs, 3 leftover specs" do
      expected = RspecBooster::Error
      write_report_file('{"malformed": []}')

      expect(RspecBooster.new(0).select).to eq(expected)
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

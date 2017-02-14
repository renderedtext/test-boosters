require 'spec_helper'

describe TestBoosters do
  it 'has a version number' do
    expect(TestBoosters::VERSION).not_to be nil
  end

  context "test file sorting" do
    it "tests for empty array" do
      expect(sort_by_size([])).to eq([])
    end

    it "tests single element array" do
      expect(sort_by_size([a])).to eq([a])
    end

    it "tests for non-existent file in array" do
      expect(sort_by_size(["non-existent"])).to eq([])
    end

    it "tests regular input" do
      input    = input_specs
      expected = expected_specs
      expect(sort_by_size(input)).to eq(expected)
    end

    it "tests regular input with non-existent files" do
      input    = input_specs
      expected = expected_specs
      expect(sort_by_size(input)).to eq(expected)
    end
  end

  context "test select_leftover_specs()" do
    it "no leftover specs" do
      expect(select_leftover_specs([], 3, 0)).to eq([])
    end

    it "1 leftover spec, 3 threads, index 0" do
      expect(select_leftover_specs([a], 3, 0)).to eq([a])
    end

    it "1 leftover spec, 3 threads, index 2" do
      expect(select_leftover_specs([a], 3, 2)).to eq([])
    end

    it "3 leftover specs, 2 threads, index 0" do
      input    = input_specs
      expected = [a, b]
      expect(select_leftover_specs(input, 2, 0)).to eq(expected)
    end

    it "3 leftover specs, 2 threads, index 1" do
      input    = input_specs
      expected = [c]
      expect(select_leftover_specs(input, 2, 1)).to eq(expected)
    end

    it "3 leftover specs, 3 threads, index 0" do
      input    = input_specs
      expected = [a]
      expect(select_leftover_specs(input, 3, 0)).to eq(expected)
    end

    it "3 leftover specs, 3 threads, index 2" do
      input    = input_specs
      expected = [b]
      expect(select_leftover_specs(input, 3, 2)).to eq(expected)
    end
  end

  context "test run()" do
    it "2 threads running in thread 1, no scheduled specs, 3 leftover specs" do
      expected = [a, b]
      report = '[{"files": []}, {"files": []}]'
      report_file = "/tmp/rspec_report.json"
      File.write(report_file, report)
      ENV["REPORT_PATH"] = report_file
      ENV["SPEC_PATH"]   = "test_data"

      expect(run(0)).to eq(expected)
    end

    it "2 threads running in thread 2, no scheduled specs, 3 leftover specs" do
      expected = [c]
      report = '[{"files": []}, {"files": []}]'
      report_file = "/tmp/rspec_report.json"
      File.write(report_file, report)
      ENV["REPORT_PATH"] = report_file
      ENV["SPEC_PATH"]   = "test_data"

      expect(run(1)).to eq(expected)
    end

    it "4 threads running in thread 4, no scheduled specs, 3 leftover specs" do
      expected = []
      report = '[{"files": []}, {"files": []}, {"files": []}, {"files": []}]'
      report_file = "/tmp/rspec_report.json"
      File.write(report_file, report)
      ENV["REPORT_PATH"] = report_file
      ENV["SPEC_PATH"]   = "test_data"

      expect(run(3)).to eq(expected)
    end
  end

  def a() "test_data/a_spec.rb" end
  def b() "test_data/b_spec.rb" end
  def c() "test_data/c_spec.rb" end

  def input_specs()     [a, b, c]  end

  def expected_specs()  [a, c, b]  end
end

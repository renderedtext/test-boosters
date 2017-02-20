require 'spec_helper'

CuBooster = Semaphore::CucumberBooster

describe Semaphore::CucumberBooster do
  context "test select()" do
    before(:context) do
      @report_file = "/tmp/rspec_report.json"
      ENV["REPORT_PATH"] = @report_file
      ENV["SPEC_PATH"]   = "test_data"
    end

    it "2 threads running in thread 1, no scheduled specs, 3 leftover specs" do
      expected = [a, b]
      write_report_file('[{"files": []}, {"files": []}]')

      expect(CuBooster.new(0).select).to eq(expected)
    end

    it "2 threads running in thread 2, no scheduled specs, 3 leftover specs" do
      expected = [c]
      write_report_file('[{"files": []}, {"files": []}]')

      expect(CuBooster.new(1).select).to eq(expected)
    end

    it "4 threads running in thread 4, no scheduled specs, 3 leftover specs" do
      expected = []
      write_report_file('[{"files": []}, {"files": []}, {"files": []}, {"files": []}]')

      expect(CuBooster.new(3).select).to eq(expected)
    end

    it "4 threads, running in thread 1, no scheduled specs, 3 leftover specs" do
      expected = CuBooster::Error
      write_report_file('{"malformed": []}')

      expect(CuBooster.new(0).select).to eq(expected)
    end

    def write_report_file(report)
      File.write(@report_file, report)
    end
  end

  def a() Setup::Cucumber.a end
  def b() Setup::Cucumber.b end
  def c() Setup::Cucumber.c end

  def input_specs() Setup::Cucumber.input_specs  end

  def expected_specs()  Setup::Cucumber.expected_specs  end
end

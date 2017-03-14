require 'spec_helper'

CuBooster = Semaphore::CucumberBooster

describe Semaphore::CucumberBooster do
  describe "test select()" do
    before(:context) do
      @test_split_configuration = "/tmp/cucumber_split_configuration.json"
      ENV["CUCUMBER_SPLIT_CONFIGURATION_PATH"] = @test_split_configuration
      ENV["SPEC_PATH"]   = "test_data"
    end

    it "2 threads running in thread 1, no scheduled specs, 3 leftover specs" do
      expected = [a, b]
      write_split_configuration_file('[{"files": []}, {"files": []}]')

      expect(CuBooster.new(0).select).to eq(expected)
    end

    it "2 threads running in thread 2, no scheduled specs, 3 leftover specs" do
      expected = [c]
      write_split_configuration_file('[{"files": []}, {"files": []}]')

      expect(CuBooster.new(1).select).to eq(expected)
    end

    it "4 threads running in thread 4, no scheduled specs, 3 leftover specs" do
      expected = []
      write_split_configuration_file('[{"files": []}, {"files": []}, {"files": []}, {"files": []}]')

      expect(CuBooster.new(3).select).to eq(expected)
    end

    it "4 threads, running in thread 1, no scheduled specs, 3 leftover specs" do
      write_split_configuration_file('{"malformed": []}')

      expect{CuBooster.new(0).select}.to raise_error(StandardError)
    end
  end

  describe "script invocation" do
    before(:context) do
      @scripts = "exe"
      @test_split_configuration = "/tmp/cucumber_split_configuration.json"
      ENV["CUCUMBER_SPLIT_CONFIGURATION_PATH"] = @test_split_configuration
      write_split_configuration_file('[{"files": []}]')
    end

    it "checks exit code - test pass" do
      ENV["SPEC_PATH"]   = "features"

      exit_state = system("#{@scripts}/cucumber_booster --thread 1")
      expect(exit_state).to eq(true)
    end
  end

  describe "attr_reader :report_path" do
    it "generates REPORT_PATH from HOME dir" do
      ENV["HOME"] = "/tmp"
      booster = CuBooster.new(0)
      expect(booster.report_path).to eq("/tmp/rspec_report.json")
    end
  end

  def write_split_configuration_file(report)
    File.write(@test_split_configuration, report)
  end

  def a() Setup::Cucumber.a end
  def b() Setup::Cucumber.b end
  def c() Setup::Cucumber.c end

  def input_specs() Setup::Cucumber.input_specs  end

  def expected_specs()  Setup::Cucumber.expected_specs  end
end

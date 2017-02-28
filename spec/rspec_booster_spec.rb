require 'spec_helper'

Booster = Semaphore::RspecBooster

describe Semaphore::RspecBooster do
  it 'has a version number' do
    expect(TestBoosters::VERSION).not_to be nil
  end

  context "test select()" do
    before(:context) do
      @report_file = "/tmp/rspec_report.json"
      ENV["REPORT_PATH"] = @report_file
      ENV["SPEC_PATH"]   = Setup.spec_dir()
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
      write_report_file('{"malformed": []}')

      expect{Booster.new(0).select}.to raise_error(StandardError)
    end

  end

  def a() Setup.a end
  def b() Setup.b end
  def c() Setup.c end

  def input_specs() Setup.input_specs  end

  def expected_specs()  Setup.expected_specs  end

  context "report-file creation" do
    before(:context) do
      @report_file = "/tmp/rspec_report.json"
      ENV["REPORT_PATH"] = @report_file
    end

    it "runs rspec and checks for report file existence" do
      spec_dir = Setup.spec_dir()

      File.delete(@report_file) if File.exist?(@report_file)
      expect(Booster.new(0).run_command(spec_dir)).to eq(0)
      expect(File).to exist(@report_file)
    end
  end

  def write_report_file(report)
    File.write(@report_file, report)
  end
end

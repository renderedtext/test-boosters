require 'spec_helper'

Booster = Semaphore::RspecBooster

describe Semaphore::RspecBooster do
  it 'has a version number' do
    expect(TestBoosters::VERSION).not_to be nil
  end

  before do
    @report_file = "#{ENV["HOME"]}/rspec_report.json"
  end

  describe "test select()" do
    before(:context) do
      @test_distribution_file = "/tmp/rspec_file_distribution.json"
      ENV["RSPEC_FILE_DISTRIBUTION_PATH"] = @test_distribution_file
      ENV["SPEC_PATH"] = Setup.spec_dir()
    end

    it "2 threads running in thread 1, no scheduled specs, 3 leftover specs" do
      expected = [a, b]
      write_test_distribution_file('[{"files": []}, {"files": []}]')

      expect(Booster.new(0).select).to eq(expected)
    end

    it "2 threads running in thread 2, no scheduled specs, 3 leftover specs" do
      expected = [c]
      write_test_distribution_file('[{"files": []}, {"files": []}]')

      expect(Booster.new(1).select).to eq(expected)
    end

    it "4 threads running in thread 4, no scheduled specs, 3 leftover specs" do
      expected = []
      write_test_distribution_file('[{"files": []}, {"files": []}, {"files": []}, {"files": []}]')

      expect(Booster.new(3).select).to eq(expected)
    end

    it "4 threads, running in thread 1, no scheduled specs, 3 leftover specs" do
      write_test_distribution_file('{"malformed": []}')

      expect{Booster.new(0).select}.to raise_error(StandardError)
    end

  end

  def a() Setup.a end
  def b() Setup.b end
  def c() Setup.c end

  def input_specs() Setup.input_specs  end

  def expected_specs()  Setup.expected_specs  end

  describe "report-file creation" do
    before(:context) do
      @test_distribution_file = "/tmp/rspec_file_distribution.json"
      ENV["FILE_DISTRIBUTION_PATH"] = @test_distribution_file
    end

    it "runs rspec and checks for report file existence" do
      spec_dir = Setup.spec_dir()

      File.delete(@test_distribution_file) if File.exist?(@test_distribution_file)
      expect(Booster.new(0).run_command(spec_dir)).to eq(0)
      expect(File).to exist(@report_file)
    end
  end

  describe "script invocation" do
    before(:context) do
      @scripts = "exe"

      @test_distribution_file = "/tmp/rspec_file_distribution.json"
      ENV["RSPEC_FILE_DISTRIBUTION_PATH"] = @test_distribution_file

      @report_file = "/tmp/rspec_report.json"
      ENV["REPORT_PATH"] = @report_file

      write_test_distribution_file('[{"files": []}]')
    end

    it "checks exit code - test fail" do
      ENV["SPEC_PATH"]   = "test_data_fail"

      exit_state = system("#{@scripts}/rspec_booster --thread 1 > /dev/null")
      expect(exit_state).to eq(false)
    end

    it "checks exit code - test pass" do
      ENV["SPEC_PATH"]   = "test_data_pass"

      exit_state = system("#{@scripts}/rspec_booster --thread 1 > /dev/null")
      expect(exit_state).to eq(true)
    end

    it "checks exit code - error while parsing" do
      ENV["SPEC_PATH"]   = "test_data_pass"

      exit_state = system("#{@scripts}/rspec_booster --thread 2 ")
      expect(exit_state).to eq(true)
    end
  end

  def write_test_distribution_file(report)
    File.write(@test_distribution_file, report)
  end
end

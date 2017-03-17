require "spec_helper"

describe TestBoosters::RspecBooster do
  before do
    @report_file = "#{ENV["HOME"]}/rspec_report.json"
  end

  describe "test select()" do
    before(:context) do
      @test_split_configuration = "/tmp/rspec_split_configuration.json"
      ENV["RSPEC_SPLIT_CONFIGURATION_PATH"] = @test_split_configuration
      ENV["SPEC_PATH"] = Setup.spec_dir()
    end

    it "2 threads running in thread 1, no scheduled specs, 3 leftover specs" do
      expected = [a, b]
      write_split_configuration_file('[{"files": []}, {"files": []}]')

      expect(described_class.new(0).select).to eq(expected)
    end

    it "2 threads running in thread 2, no scheduled specs, 3 leftover specs" do
      expected = [c]
      write_split_configuration_file('[{"files": []}, {"files": []}]')

      expect(described_class.new(1).select).to eq(expected)
    end

    it "4 threads running in thread 4, no scheduled specs, 3 leftover specs" do
      expected = []
      write_split_configuration_file('[{"files": []}, {"files": []}, {"files": []}, {"files": []}]')

      expect(described_class.new(3).select).to eq(expected)
    end

    it "4 threads, running in thread 1, no scheduled specs, 3 leftover specs" do
      write_split_configuration_file('{"malformed": []}')

      expect { described_class.new(0).select }.to raise_error(StandardError)
    end

  end

  def a() Setup.a end
  def b() Setup.b end
  def c() Setup.c end

  def input_specs() Setup.input_specs  end

  def expected_specs()  Setup.expected_specs  end

  describe "report-file creation" do
    before(:context) do
      @test_split_configuration = "/tmp/rspec_split_configuration.json"
      ENV["FILE_DISTRIBUTION_PATH"] = @test_split_configuration
    end

    it "runs rspec and checks for report file existence" do
      spec_dir = Setup.spec_dir()

      File.delete(@test_split_configuration) if File.exist?(@test_split_configuration)
      expect(described_class.new(0).run_command(spec_dir)).to eq(0)
      expect(File).to exist(@report_file)
    end
  end

  describe "script invocation" do
    before(:context) do
      @scripts = "exe"

      @test_split_configuration = "/tmp/rspec_split_configuration.json"
      ENV["RSPEC_SPLIT_CONFIGURATION_PATH"] = @test_split_configuration

      @report_file = "/tmp/rspec_report.json"
      ENV["REPORT_PATH"] = @report_file

      write_split_configuration_file('[{"files": []}]')
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

  describe "attr_reader :report_path" do
    it "reads REPORT_PATH" do
      ENV["REPORT_PATH"] = "qwerty"
      booster = described_class.new(0)
      expect(booster.report_path).to eq("qwerty")
      ENV.tap { |hs| hs.delete("REPORT_PATH") }
    end

    it "generates REPORT_PATH from HOME dir" do
      ENV["HOME"] = "/tmp"
      booster = described_class.new(0)
      expect(booster.report_path).to eq("/tmp/rspec_report.json")
    end
  end

  def write_split_configuration_file(report)
    File.write(@test_split_configuration, report)
  end
end

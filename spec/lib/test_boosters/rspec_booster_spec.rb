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

    it "displays thread index and thread count" do
      write_split_configuration_file('[{"files": []}, {"files": []}]')

      ENV["SPEC_PATH"] = "test_data_pass"
      output = `#{@scripts}/rspec_booster --thread 2`

      expect(output).to include("Running RSpec thread 2 out of 2 threads")
    end

    context "when no tests are present" do
      before do
        ENV["SPEC_PATH"] = "test_data_no_files"
      end

      it "returns 0 as exit status" do
        system("#{@scripts}/rspec_booster --thread 1")

        expect($?.exitstatus).to eq(0)
      end
    end

    context "when some rspec tests fail" do
      before do
        ENV["SPEC_PATH"] = "test_data_fail"
      end

      it "returns 1 as exit status" do
        system("#{@scripts}/rspec_booster --thread 1 > /dev/null")

        expect($?.exitstatus).to eq(1)
      end
    end

    context "when all rspec tests pass" do
      before do
        ENV["SPEC_PATH"] = "test_data_pass"
      end

      it "returns 0 as exit status" do
        system("#{@scripts}/rspec_booster --thread 1 > /dev/null")

        expect($?.exitstatus).to eq(0)
      end
    end

    context "when an error happens while parsing input" do
      before do
        ENV["SPEC_PATH"] = "test_data_pass"
      end

      it "handles the error and return exit status 0" do
        # there is only one rspec thread
        # if we pass --thread 2, the execution should fail
        system("#{@scripts}/rspec_booster --thread 2 > /dev/null 2>&1")

        expect($?.exitstatus).to eq(0)
      end
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

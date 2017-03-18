require "spec_helper"

describe TestBoosters::Rspec::Booster do

  let(:specs_path) { "/tmp/rspec_tests" }

  before do
    FileUtils.rm_rf(specs_path)
    FileUtils.mkdir_p(specs_path)

    ENV["SPEC_PATH"] = specs_path
  end

end

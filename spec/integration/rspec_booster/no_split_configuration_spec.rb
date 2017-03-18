require "spec_helper"

describe "RSpec Booster behvaviour when there is no split configuration" do

  before do
    ENV["SPEC_PATH"] = "fixtures/green_rspec_project/spec"
  end

  it "runs specs based on leftover files colculation" do
  end

end

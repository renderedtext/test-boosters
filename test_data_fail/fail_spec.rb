require 'spec_helper'

# Booster = Semaphore::RspecBooster

describe Semaphore::RspecBooster do
  it 'fails' do
    expect(TestBoosters::VERSION).to be "wrong"
  end
end

module TestBoosters
  class RspecBooster

    def initialize(thread_index)
      @thread_index = thread_index
      @specs = TestBoosters::RSpec::Specs.new(@thread_index)
    end

    def run
      current_thread = @specs.threads[@thread_index]

      current_thread.run
    end

  end
end

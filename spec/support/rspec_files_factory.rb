require "securerandom"

module Support
  module RspecFilesFactory
    module_function

    def create(options = {})
      path    = options[:path]
      content = options[:content] || create_rspec_content(options[:result] || :passing)

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)
    end

    # :reek:DuplicateMethodCall
    def create_rspec_content(result)
      <<-RSPEC_FILE
      require "spec_helper"

      describe RandomTest-#{SecureRandom.uuid} do
        it "does something interesting #{SecureRandom.uuid}" do
          expect(1 + 1).to eq(#{result == :passing ? 2 : 42})
        end
      end
      RSPEC_FILE
    end

  end
end

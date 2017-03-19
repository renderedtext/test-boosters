module Support
  module RspecFilesFactory
    module_function

    def create(options = {})
      path    = options[:path]
      name    = options[:name] || "RandomTest"
      result  = options[:result] || :passing

      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, create_rspec_content(name, result))
    end

    def create_rspec_content(name, result)
      <<-RSPEC_FILE
      require "spec_helper"

      describe "##{name}" do
        it "makes sure that #{name} works" do
          expect(1 + 1).to eq(#{result == :passing ? 2 : 42})
        end
      end
      RSPEC_FILE
    end

  end
end

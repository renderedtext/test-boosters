module Support
  module SplitConfigurationFactory
    module_function

    def create(options = {})
      path    = options[:path]
      content = options[:content]

      File.write(path, content.to_json)
    end

  end
end

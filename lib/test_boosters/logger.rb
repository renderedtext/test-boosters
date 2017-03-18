module TestBoosters
  module Logger
    module_function

    # TODO: why are we logging info messages into the error log?
    def info(message)
      error_log_path = ENV["ERROR_LOG_PATH"] || "#{ENV["HOME"]}/test_booster_error.log"

      File.open(error_log_path, "a") { |file| file.write("#{message}\n") }
    end

    def error(message)
      error_log_path = ENV["ERROR_LOG_PATH"] || "#{ENV["HOME"]}/test_booster_error.log"

      File.open(error_log_path, "a") { |file| file.write("#{message}\n") }
    end

  end
end

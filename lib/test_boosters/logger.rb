def log(message)
  error_log_path = ENV["ERROR_LOG_PATH"] || "#{ENV["HOME"]}/test_booster_error.log"

  File.open(error_log_path, "a") { |f| f.write("#{message}\n") }
end

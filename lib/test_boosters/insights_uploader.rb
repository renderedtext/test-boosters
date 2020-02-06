module TestBoosters
  module InsightsUploader
    module_function

    def upload(booster_type, file)
      # return unless File.exist?(file)

      # cmd = "http POST '#{insights_url}' #{booster_type}:=@#{file}"

      # TestBoosters::Shell.execute("#{cmd} > ~/insights_uploader.log", :silent => true)
    end

    def insights_url
      params = {
        :project_hash_id => ENV["SEMAPHORE_PROJECT_UUID"],
        :build_hash_id => ENV["SEMAPHORE_EXECUTABLE_UUID"],
        :job_hash_id => ENV["SEMAPHORE_JOB_UUID"]
      }

      "https://insights-receiver.semaphoreci.com/job_reports?#{::URI.encode_www_form(params)}"
    end

  end
end

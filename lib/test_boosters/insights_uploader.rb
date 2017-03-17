module TestBoosters
  class InsightsUploader
    def initialize
      @project_hash_id = ENV["SEMAPHORE_PROJECT_UUID"]
      @build_hash_id = ENV["SEMAPHORE_EXECUTABLE_UUID"]
      @job_hash_id = ENV["SEMAPHORE_JOB_UUID"]
    end

    def upload(booster_type, file)
      url = "https://insights-receiver.semaphoreci.com/job_reports" +
            "?job_hash_id=#{@job_hash_id}" +
            "&build_hash_id=#{@build_hash_id}" +
            "&project_hash_id=#{@project_hash_id}"
      cmd = "http POST '#{url}' #{booster_type}:=@#{file}"

      TestBoosters.execute("#{cmd} > ~/insights_uploader.log")
    end
  end
end

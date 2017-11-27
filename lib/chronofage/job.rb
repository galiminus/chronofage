module Chronofage
  class Job < ::ActiveRecord::Base
    self.table_name = "chronofage_jobs"

    scope :ready, -> { where(started_at: nil) }

    def execute!
      start!
      job_class.constantize.perform_now(*deserialized_arguments)
      done!
    rescue
      failed!
      raise
    end

    def start!
      update(started_at: Time.now)
    end

    def done!
      update(completed_at: Time.now)
    end

    def failed!
      update(failed_at: Time.now)
    end

    def deserialized_arguments
      ActiveJob::Arguments.deserialize(JSON.parse(arguments))
    end

  end
end

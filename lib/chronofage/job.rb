module Chronofage
  class Job < ::ActiveRecord::Base
    self.table_name = "chronofage_jobs"

    scope :ready, -> { where(started_at: nil) }
    scope :started, -> { where.not(started_at: nil).where(failed_at: nil, completed_at: nil) }

    def self.next(queue_name)
      ready.where(queue_name: queue_name).order(priority: :asc).first
    end

    def execute!
      start!
      job_class.constantize.perform_now(*deserialized_arguments)
      done!
    rescue
      failed!
      raise
    end

    def start!
      update!(started_at: Time.now, host: Chronofage::Job.host)
    end

    def done!
      update!(completed_at: Time.now)
    end

    def failed!
      update!(failed_at: Time.now)
    end

    def deserialized_arguments
      ActiveJob::Arguments.deserialize(JSON.parse(arguments))
    end

    def concurrents
      Chronofage::Job.started.where(queue_name: queue_name, host: Chronofage::Job.host)
    end

    def state
      if started_at.present? && completed_at.present?
        :completed
      elsif started_at.present? && failed_at.present?
        :failed
      elsif started_at.present?
        :running
      else
        :ready
      end
    end

    private

    def self.host
      Socket.gethostname
    end

  end
end

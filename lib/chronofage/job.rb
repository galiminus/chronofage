module Chronofage
  class Job < ::ActiveRecord::Base
    self.table_name = "chronofage_jobs"

    scope :ready, -> { where(started_at: nil) }
    scope :started, -> { where.not(started_at: nil).where(failed_at: nil, completed_at: nil) }

    def self.next(queue_name)
      ready.where(queue_name: queue_name).order(priority: :asc).first
    end

    def perform
      started!
      output = ActiveJob::Base.execute(job_data)
      completed!(output)
    rescue Exception => error
      failed!("#{error.message}\n#{error.backtrace.join("\n")}")
      raise
    end

    def started!
      update!(started_at: Time.now, host: Chronofage::Job.host)
    end

    def completed!(output = nil)
      update!(completed_at: Time.now, output: output)
    end

    def failed!(output = nil)
      update!(failed_at: Time.now, output: output)
    end

    def ready?
      state == :ready
    end

    def started?
      state == :started
    end

    def failed?
      state == :failed
    end

    def completed?
      state == :completed
    end

    def retry!
      job_class.constantize.perform_later(*(ActiveJob::Arguments.deserialize(job_data["arguments"])))
    end

    def job_data
      JSON.parse(arguments)
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
        :started
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

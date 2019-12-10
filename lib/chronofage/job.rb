module Chronofage
  class Job < ::ActiveRecord::Base
    self.table_name = "chronofage_jobs"

    scope :not_timed_out, -> { where("(started_at + (timeout_delay || ' minutes')::interval) > ?", Time.now).or(where(timeout_delay: nil)) }
    scope :ready, -> { where(started_at: nil) }
    scope :started, -> { where.not(started_at: nil).where(failed_at: nil, completed_at: nil) }
    scope :available, -> { ready.where('scheduled_at <= ?', Time.now).or(where(scheduled_at: nil)) }

    def self.take_next(queue_name, concurrency, global_concurrency)
      ActiveRecord::Base.transaction do
        ActiveRecord::Base.connection.execute('LOCK chronofage_jobs IN ACCESS EXCLUSIVE MODE')

        job = ready.available.where(queue_name: queue_name).order(priority: :asc).first
        if job.present? && job.concurrents.count < concurrency && (global_concurrency == 0 || job.global_concurrents.count < global_concurrency)
          job.started!
          job
        else
          nil
        end
      end
    end

    def perform
      output = ActiveJob::Base.execute(job_data)
      completed!(output)
    rescue Exception => error
      failed!("#{error.message}\n#{error.backtrace.join("\n")}")
      raise
    end

    def started!
      update!(started_at: Time.now, host: Chronofage::Job.host, pid: pid)
    end

    def completed!(output = nil)
      update!(completed_at: Time.now, output: output)
    end

    def failed!(output = nil)
      # Sometime we fail because we lose the connection to the database, in that case we retry a few times

      retries = 3
      begin
        update!(failed_at: Time.now, output: output)
      rescue => error
        raise error if retries == 0
        retries -= 1

        sleep 5
        retry
      end
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
      global_concurrents.where(host: Chronofage::Job.host)
    end

    def global_concurrents
      Chronofage::Job.started.not_timed_out.where(queue_name: queue_name)
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

    def self.pid
      Process.pid
    end

    def self.host
      Socket.gethostname
    end

  end
end

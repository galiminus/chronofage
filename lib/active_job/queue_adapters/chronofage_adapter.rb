module ActiveJob
  module QueueAdapters
    class ChronofageAdapter
      def enqueue(job)
        Chronofage::Job.create!({
          job_class: job.class,
          arguments: job.serialize.to_json,
          job_id: job.job_id,
          queue_name: job.queue_name,
          priority: job.priority || 0
        })
      end

      def enqueue_at(job)
        raise NotImplementedError, "Chronofage doesn't support enqueue_at."
      end
    end
  end
end

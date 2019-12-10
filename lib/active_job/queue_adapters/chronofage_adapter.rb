module ActiveJob
  module QueueAdapters
    class ChronofageAdapter

      def enqueue(active_job)
        chronofage_job = build_chronofage_job_for(active_job)
        chronofage_job.save!
      end

      def enqueue_at(active_job, timestamp)
        chronofage_job = build_chronofage_job_for(active_job)
        chronofage_job.scheduled_at = Time.at(timestamp).to_datetime
        chronofage_job.save!
      end

      private

      def build_chronofage_job_for(active_job)
        attributes = {
          job_class: active_job.class,
          arguments: active_job.serialize.to_json,
          job_id: active_job.job_id,
          queue_name: active_job.queue_name,
          priority: active_job.priority || 0
        }

        extra_attributes = active_job.arguments.last.try(:[], :extra_attributes) || {}

        Chronofage::Job.new(attributes.merge(extra_attributes))
      end

    end
  end
end

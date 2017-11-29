namespace :chronofage_engine do
  namespace :jobs do
    task :execute, [:queue_name, :concurrency] => :environment do |t, args|
      job = Chronofage::Job.next(args.queue_name)
      if job.present? && job.concurrents.count < args.concurrency.to_i
        job.execute!
      end
    end
  end
end

namespace :chronofage_engine do
  namespace :jobs do
    task :execute, [:queue_name, :concurrency] => :environment do |t, args|
      job = Chronofage::Job.take_next(args.queue_name, args.concurrency.to_i)
      job.perform if job.present?
    end
  end
end

namespace :chronofage_engine do
  namespace :jobs do
    task :execute, [:queue_name, :concurrency, :global_concurrency] => :environment do |t, args|
      job = Chronofage::Job.take_next(args.queue_name, args.concurrency.to_i, args.global_concurrency.to_i)
      job.perform if job.present?
    end

    task :poll, [:queue_name, :concurrency, :global_concurrency] => :environment do |t, args|
      loop do
        job = Chronofage::Job.take_next(args.queue_name, args.concurrency.to_i, args.global_concurrency.to_i)
        if job.blank?
          sleep 1
          next
        end

        ActiveRecord::Base.connection.disconnect!

        pid = fork do
          Process.daemon

          ActiveRecord::Base.establish_connection
          job.perform
        end
        Process.detach(pid)

        ActiveRecord::Base.establish_connection
      end
    end
  end
end

namespace :chronofage_engine do
  namespace :jobs do
    task :execute, [:queue_name, :concurrency] => :environment do |t, args|
      job = Chronofage::Job.ready.where(queue_name: args.queue_name).order(priority: :asc).first

      if job.nil?
        Rails.logger.info "chronofage[#{args.queue_name}]: no job to execute."
      else
        runner = Chronofage::Runner.register!(args.queue_name, args.concurrency.to_i)
        begin
          job.execute!
        ensure
          runner.unregister!
        end
      end
    end
  end
end

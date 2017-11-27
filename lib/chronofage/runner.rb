require 'socket'

module Chronofage
  class Runner < ::ActiveRecord::Base
    self.table_name = "chronofage_runners"

    class MaxConcurrencyReached < StandardError
    end

    def self.register!(queue_name, concurrency)
      if concurrent_runnners(queue_name).count >= concurrency
        raise MaxConcurrencyReached
      else
        create!(queue_name: queue_name, host: host)
      end
    end

    def self.concurrent_runnners(queue_name)
      where(queue_name: queue_name, host: host)
    end

    def unregister!
      destroy!
    end

    private

    def self.host
      Socket.gethostname
    end

  end
end

module ActiveJob
  module QueueAdapters
    # == Active Job Disabled adapter
    #
    # This adapter silently does nothing when jobs are enqueued
    #
    # To use the Inline set the queue_adapter config to +:disabled+.
    #
    #   Rails.application.config.active_job.queue_adapter = :disabled
    class DisabledAdapter
      class << self
        def enqueue(job) #:nodoc:
        end
        def enqueue_at(*) #:nodoc:
        end
      end
    end

  end
end

module DelayedPaperclip
  module Jobs
    class ActiveJob < ActiveJob::Base
      
      queue_as :paperclip

      def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name)
        # ActiveJob currently does not support symbol arguments
        self.perform_later(instance_klass, instance_id, attachment_name.to_s)
      end

      def perform(instance_klass, instance_id, attachment_name)
        DelayedPaperclip.process_job(instance_klass, instance_id, attachment_name.to_sym)
      end
    end
  end
end
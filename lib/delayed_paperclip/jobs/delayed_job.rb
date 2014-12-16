require 'delayed_job'

module DelayedPaperclip
  module Jobs
    class HerokuJob
      def initialize
        if Rails.env.production?
          @heroku ||= HerokuManager.new
          @heroku.set_workers(1) if (@heroku.get_workers == 0)
        end
      end

      def perform; end

      def after(job)
        if Rails.env.production?
          @heroku ||= HerokuManager.new
          @heroku.set_workers(0) if (job_count == 1)
        end
      end

      def job_count
        Delayed::Job.where('failed_at IS NULL').length
      end
    end

    class HerokuManager
      def heroku
        @heroku ||= Heroku::API.new
      end

      def get_workers
        heroku.get_ps(ENV['APP_NAME']).body.count { |p| p["process"] =~ /worker\.\d?/ }
      end

      def set_workers(count)
        heroku.post_ps_scale(ENV['APP_NAME'], 'worker', count)
      end
    end

    class DelayedJob < Struct.new(:instance_klass, :instance_id, :attachment_name)
    # include DelayedPaperclip::HerokuJob

      if Gem.loaded_specs['delayed_job'].version >= Gem::Version.new("2.1.0") # this is available in newer versions of DelayedJob. Using the newee Job api thus.

        def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name)
          ::Delayed::Job.enqueue(
            :payload_object => new(instance_klass, instance_id, attachment_name),
            :priority => instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:priority].to_i,
            :queue => instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:queue]
          )
        end

      else

        def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name)
          ::Delayed::Job.enqueue(
            new(instance_klass, instance_id, attachment_name),
            instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:priority].to_i,
            instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:queue]
          )
        end

      end

      def perform
        DelayedPaperclip.process_job(instance_klass, instance_id, attachment_name)
      end
    end
  end
end
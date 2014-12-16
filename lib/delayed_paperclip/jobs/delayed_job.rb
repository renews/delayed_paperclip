require 'delayed_job'

module DelayedPaperclip
  module Jobs
    class DelayedJob < Struct.new(:instance_klass, :instance_id, :attachment_name)
      Logger.new(STDOUT).debug '=[=========================================================='
      Logger.new(STDOUT).debug 'delayed_job.rb'
    # extend DelayedPaperclip::Jobs::HerokuJob
      def initialize
        if Rails.env.production?
          @heroku ||= HerokuManager.new
          Logger.new(STDOUT).debug('initializer')
          @heroku.set_workers(1) if (@heroku.get_workers == 0)
          Logger.new(STDOUT).debug('workers'<<@heroku.get_workers.to_s)
          sleep 10
        end
      end

      def after(job)
        if Rails.env.production?
          @heroku ||= HerokuManager.new
          Logger.new(STDOUT).debug 'after'
          @heroku.set_workers(0) if (job_count == 1)
          Logger.new(STDOUT).debug 'workers'<<@heroku.get_workers.to_s
        end
      end

      def job_count
        Logger.new(STDOUT).debug 'job count'
        Logger.new(STDOUT).debug(Delayed::Job.where('failed_at IS NULL').length)
        Delayed::Job.where('failed_at IS NULL').length
      end

      if Gem.loaded_specs['delayed_job'].version >= Gem::Version.new("2.1.0") # this is available in newer versions of DelayedJob. Using the newee Job api thus.
        Logger.new(STDOUT).debug 'gem  newer'

        def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name)
          Logger.new(STDOUT).debug('='<<instance_klass.to_s<<instance_id.to_s<<attachment_name.to_s)
          ::Delayed::Job.enqueue(
            :payload_object => new(instance_klass, instance_id, attachment_name),
            :priority => instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:priority].to_i,
            :queue => instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:queue]
          )
        end

      else
        Logger.new(STDOUT).debug 'gem old'
        def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name)
          Logger.new(STDOUT).debug('='<<instance_klass.to_s<<instance_id.to_s<<attachment_name.to_s)
          ::Delayed::Job.enqueue(
            new(instance_klass, instance_id, attachment_name),
            instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:priority].to_i,
            instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:queue]
          )
        end

      end

      def perform
        Logger.new(STDOUT).debug 'perform'
        Logger.new(STDOUT).debug('perform='<<instance_klass.to_s<<instance_id.to_s<<attachment_name.to_s)
        DelayedPaperclip.process_job(instance_klass, instance_id, attachment_name)
      end
      @Logger.new(STDOUT).debug '=[=========================================================='
    end
  end
end
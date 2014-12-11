class HerokuJob < Struct.new(:instance_klass, :instance_id, :attachment_name)
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
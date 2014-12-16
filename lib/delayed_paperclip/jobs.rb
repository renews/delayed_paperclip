module DelayedPaperclip
  module Jobs
    autoload :ActiveJob,  'delayed_paperclip/jobs/active_job'
    autoload :DelayedJob, 'delayed_paperclip/jobs/delayed_job'
    autoload :Resque,     'delayed_paperclip/jobs/resque'
    autoload :Sidekiq,    'delayed_paperclip/jobs/sidekiq'
    autoload :HerokuJob,   'delayed_paperclip/heroku_job'
    autoload :HerokuManager,   'delayed_paperclip/heroku_manager'
  end
end

module DelayedPaperclip
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
end
namespace :jobs do
  namespace :queue do
    desc "Start job queues and runners."
    task :start do
      `RAILS_ENV=production bundle exec bin/delayed_job --pool=internal:5 --pool=external:6 start`
    end

    desc "Stop job queues and runners."
    task :stop do
      `RAILS_ENV=production bundle exec bin/delayed_job stop`
      `ps -ef | grep delayed | grep -v grep | awk '{print $2}' | xargs kill && rm tmp/pids/*`
    end
  end
end

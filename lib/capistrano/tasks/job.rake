namespace :job do
  namespace :queue do
    desc "Start job queues and runners."
    task :start do
      on roles(:all) do
        within release_path do
          with rails_env: :production do
            execute "RAILS_ENV=production bundle exec bin/delayed_job --pool=internal:5 --pool=external:6 start"
          end
        end
      end
    end
    desc "Stop job queues and runners."
    task :stop do
      on roles(:all) do
        within release_path do
          with rails_env: :production do
            execute "RAILS_ENV=production bundle exec bin/delayed_job stop"
            execute "ps -ef | grep delayed | grep -v grep | awk '{print $2}' | xargs kill && rm tmp/pids/*"
          end
        end
      end
    end
  end
end
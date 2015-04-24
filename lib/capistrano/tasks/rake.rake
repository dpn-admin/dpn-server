namespace :rrake do
  namespace :db do
    desc "Reset the database on all servers!"
    task :reset do
      on roles(:all) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, "db:reset"
          end
        end

        #execute "#{fetch(:rbenv_prefix)} cd #{fetch(:deploy_to)}/current && bundle exec rake #{ENV['task']} RAILS_ENV=#{fetch(:rails_env)}"
      end
    end
  end
end


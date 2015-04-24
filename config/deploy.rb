# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'DPN-REST-RAILS'
set :repo_url, 'git@github.com:dpn-admin/DPN-REST-RAILS.git'
set :scm, :git
set :format, :pretty
set :pty, true
set :rbenv_type, :system
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

namespace :apache do
  desc "Restart apache"
  task :restart do
    on roles(:web) do
      execute  :sudo, "/etc/init.d/apache2 restart"
    end
  end
end

after :deploy, "apache:restart"

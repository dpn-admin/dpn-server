# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

namespace :rrake do

  desc "Clear everything then load fixtures"
  task :all do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "jobs:clear"
          execute :rake, "db:clear"
          execute :rake, "db:fixtures:load"
        end
      end
    end
  end

  desc "Run an arbitrary rake task"
  task :invoke, :command do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, args[:command]
        end
      end
    end
  end

  namespace :db do
    desc "Reset the database on all servers!"
    task :reset do
      on roles(:all) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, "db:reset"
          end
        end
      end
    end

    desc "Run rake db:clear"
    task :clear do
      on roles(:all) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, "db:clear"
          end
        end
      end
    end

    namespace :fixtures do
      desc "Run rake db:fixtures:load"
      task :load, :fixture do
        on roles(:all) do
          within release_path do
            with rails_env: fetch(:rails_env) do
              execute :rake, "db:fixtures:load #{args[:fixture]}"
            end
          end
        end
      end
    end

  end
end


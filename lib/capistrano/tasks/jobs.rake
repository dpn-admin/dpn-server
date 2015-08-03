# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

namespace :jobs do
  namespace :queue do
    desc "Start job queues and runners on the remote node."
    task :start do
      on roles(:all) do
        within release_path do
          with rails_env: :production do
            execute :rake, "jobs:queue:start"
          end
        end
      end
    end

    desc "Stop job queues and runners."
    task :stop do
      on roles(:all) do
        within release_path do
          with rails_env: :production do
            execute :rake, "jobs:queue:stop"
          end
        end
      end
    end

    desc "Run rake jobs:clear"
    task :clear do
      on roles(:all) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, "jobs:clear"
          end
        end
      end
    end
  end
end
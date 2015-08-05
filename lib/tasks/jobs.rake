# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

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

  desc "Run an arbitrary job for a specific node."
  task :run, [:jobname, :target_node, :local_node] => :environment do |t, args|
    args[:jobname].classify.constantize.perform_now(args[:target_node], args[:local_node])
  end
end

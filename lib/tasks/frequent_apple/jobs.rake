# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

namespace :frequent_apple do
  namespace :jobs do
    desc "Run an arbitrary job for a specific node."
    task :run, [:jobname, :target_node, :local_node] => :environment do |t, args|
      args[:jobname].classify.constantize.perform_now(args[:target_node], args[:local_node])
    end
  end
end

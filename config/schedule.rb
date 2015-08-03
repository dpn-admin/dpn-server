# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require "pathname"
set :path, Pathname.new(File.expand_path(__FILE__)).dirname.parent

job_type :runner,  "cd :path && bundle exec bin/rails runner -e :environment ':task' :output"

(%w(aptrust chron hathi tdr)-[ENV['DPN_NAMESPACE']]).each do |node|
  node = "\"#{node}\""
  every :hour, at: (0..55).step(5).to_a.join(",").to_sym do
    runner "FrequentApple::SyncNodeJob.perform_later(#{node})"
  end

  every :hour, at: (2..57).step(5).to_a.join(",").to_sym do
    runner "FrequentApple::SyncBagsJob.perform_later(#{node})"
  end

  every :hour, at: (4..59).step(5).to_a.join(",").to_sym do
    runner "FrequentApple::SyncReplicationTransfersJob.perform_later(#{node})"
  end

  every :hour, at: (1..56).step(5).to_a.join(",").to_sym do
    runner "FrequentApple::UpdateReplicationStatusJob.perform_later(#{node})"
  end

end

every 10.minutes do
  runner "RemoveOrphanBagMgrRequestsJob.perform_later"
end

every :reboot do
  command "cd #{path} && #{environment_variable}=#{environment} bundle exec bin/delayed_job --pool=internal:5 --pool=external:6 start"
end
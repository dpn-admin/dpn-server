#!/usr/bin/env ruby

# run_cluster.sh
#
# Runs a cluster of DPN nodes for integration testing.
# This runs 5 dpn nodes, on the following ports:
#
# aptrust - http://127.0.0.1:3001
# chron   - http://127.0.0.1:3002
# hathi   - http://127.0.0.1:3003
# sdr     - http://127.0.0.1:3004
# tdr     - http://127.0.0.1:3005
#
# Note that this wipes out data for all of the nodes and
# loads in test fixture data.
# ----------------------------------------------------------------------

# Make sure we're running from the right directory
unless File.exists? "config.ru"
  puts "Run this script from the top-level Rails directory "
  puts "for the dpn-server project. E.g. script/migrate_cluster.sh"
  exit
end

require "optparse"

load_fixtures = false

options = {}

OptionParser.new do |opts|
  opts.on("-f", "--load-fixtures", "Load local fixtures") do |f|
    load_fixtures = f
  end

  opts.on("-h", "--help", "Usage: run_cluster.sh [-f]",
    "Runs a local cluster of DPN REST services ",
    "on ports 3001-3005. Option -f will load node-specific ",
    "fixtures, including bags, replication transfers and ",
    "restore transfers for each node. Otherwise, only the ",
    "bare minimum fixture data is loaded.") do
    puts opts
    exit
  end
end.parse!

nodes = %w(aptrust chron hathi sdr tdr)

def common_assignments(node)
  "RAILS_ENV=impersonate_#{node} IMPERSONATE=#{node}"
end

nodes.each do |node|
  puts "Loading base fixture data for #{node} node"
  `#{common_assignments(node)} bundle exec rake db:fixtures:load FIXTURES_DIR=integration/common`
end

if load_fixtures
  nodes.each do |node|
    puts "Loading local bags, transfers and restores for #{node}"
    `#{common_assignments(node)} bundle exec rake db:fixtures:load FIXTURES_DIR=integration/#{node}`
  end
end

pids = []
(0..4).each do |i|
  node = nodes[i]
  port = 3000+i+1
  puts "Starting #{node} node on http://127.0.0.1:#{port}"
  pids << Process.spawn("#{common_assignments(node)} bundle exec rails server -p #{port} -P tmp/pids/impersonate_#{node}")
end

kill_all = Proc.new do
  (0..4).each do |i|
    node = nodes[i]
    port = 3000+i+1
    puts "Shutting down #{node} on http://127.0.0.1:#{port}"
    Process.kill("INT", pids[i])
  end
  puts "Sent SIGINT to all Rails processes in the cluster"
end

Signal.trap("INT") { kill_all.call }
Signal.trap("TERM") { kill_all.call }

Process.waitall

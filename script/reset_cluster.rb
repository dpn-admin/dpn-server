#!/usr/bin/env ruby

# reset_cluster.sh
#
# Resets the databases for a cluster of DPN nodes for integration testing.
# ----------------------------------------------------------------------

# Make sure we're running from the right directory
unless File.exists? "config.ru"
  puts "Run this script from the top-level Rails directory "
  puts "for the dpn-server project. E.g. script/reset_cluster.sh"
  exit
end

%w(aptrust chron hathi sdr tdr).each do |node|
  puts "Dropping db that impersonates local #{node} node."
  `RAILS_ENV=impersonate_#{node} DATABASE_URL=sqlite3:db/impersonate_#{node}.sqlite3 bundle exec rake db:drop`
  puts "Migrating db that impersonates local #{node} node."
  `RAILS_ENV=impersonate_#{node} DATABASE_URL=sqlite3:db/impersonate_#{node}.sqlite3 bundle exec rake db:setup`
end

puts "Now run script/run_cluster.sh to run the cluster"

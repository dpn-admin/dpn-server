#!/usr/bin/env ruby

# setup_cluster.sh
#
# Sets up the databases for a cluster of DPN nodes for integration testing.
# You should only need to run this once.
# ----------------------------------------------------------------------

# Make sure we're running from the right directory
unless File.exists? "config.ru"
  puts "Run this script from the top-level Rails directory "
  puts "for the dpn-server project. E.g. script/setup_cluster.sh"
  exit
end

%w(aptrust chron hathi sdr tdr).each do |node|
  puts "Setting up db that impersonates local #{node} node."
  `RAILS_ENV=impersonate IMPERSONATE=#{node} DATABASE_URL=sqlite3:db/impersonate_#{node}.sqlite3 bundle exec rake db:setup`
end

puts "Now run script/run_cluster.sh to run the cluster"
puts "to run with no pre-loaded data, or script/run_cluster.sh -f"
puts "to run with a minimal set of pre-loaded fixture data."
#!/usr/bin/env ruby

# setup_cluster.rb
#
# Sets up the databases for a cluster of DPN nodes for integration testing.
# You should only need to run this once.
# ----------------------------------------------------------------------

# Make sure we're running from the right directory
unless File.exists? "config.ru"
  puts "Run this script from the top-level Rails directory "
  puts "for the dpn-server project; e.g."
  puts "bundle exec ./script/setup_cluster.rb"
  exit
end

require 'yaml'
config_file = File.join "config", "dpn.yml"
cfg = YAML.load(IO.read(config_file))

%w(aptrust chron hathi sdr tdr).each do |node|
  if cfg.include? "impersonate_#{node}"
    puts "Found an 'impersonate_#{node}' configuration in config/dpn.yml"
  else
    puts "Add an 'impersonate_#{node}' configuration to config/dpn.yml"
    next
  end
  puts "Setting up config/environments/impersonate_#{node}.rb"
  `cp config/environments/development.rb config/environments/impersonate_#{node}.rb`
  puts "Setting up db that impersonates local #{node} node."
  `RAILS_ENV=impersonate_#{node} DATABASE_URL=sqlite3:db/impersonate_#{node}.sqlite3 bundle exec rake db:setup`
end

puts "Now run script/run_cluster.rb to run the cluster"
puts "to run with no pre-loaded data, or script/run_cluster.rb -f"
puts "to run with a minimal set of pre-loaded fixture data."

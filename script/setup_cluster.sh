#!/bin/bash
#
# setup_cluster.sh
#
# Sets up the databases for a cluster of DPN nodes for integration testing.
# You should only need to run this once.
# ----------------------------------------------------------------------

# Make sure we're running from the right directory
if [ ! -f config.ru ]; then
    echo "Run this script from the top-level Rails directory "
    echo "for the dpn-server project. E.g. script/setup_cluster.sh"
    exit
fi

echo "Setting up db to impersonate local APTrust node"
RAILS_ENV=impersonate_aptrust bundle exec rake db:setup

echo "Setting up db to impersonate local Hathi node"
RAILS_ENV=impersonate_hathi bundle exec rake db:setup

echo "Setting up db to impersonate local Chronopolis node"
RAILS_ENV=impersonate_chron bundle exec rake db:setup

echo "Setting up db to impersonate local Stanford node"
RAILS_ENV=impersonate_sdr bundle exec rake db:setup

echo "Setting up db to impersonate local Texas node"
RAILS_ENV=impersonate_tdr bundle exec rake db:setup

echo "Now run script/run_cluster.sh to run the cluster"

#!/bin/bash
#
# migrate_cluster.sh
#
# Migrates the databases for a cluster of DPN nodes for integration testing.
# ----------------------------------------------------------------------

# Make sure we're running from the right directory
if [ ! -f config.ru ]; then
    echo "Run this script from the top-level Rails directory "
    echo "for the dpn-server project. E.g. script/migrate_cluster.sh"
    exit
fi

echo "Migrating db that impersonates local APTrust node"
RAILS_ENV=impersonate_aptrust bundle exec rake db:migrate

echo "Migrating db that impersonates local Hathi node"
RAILS_ENV=impersonate_hathi bundle exec rake db:migrate

echo "Migrating db that impersonates local Chronopolis node"
RAILS_ENV=impersonate_chron bundle exec rake db:migrate

echo "Migrating db that impersonates local Stanford node"
RAILS_ENV=impersonate_sdr bundle exec rake db:migrate

echo "Migrating db that impersonates local Texas node"
RAILS_ENV=impersonate_tdr bundle exec rake db:migrate

echo "Now run script/run_cluster.sh to run the cluster"

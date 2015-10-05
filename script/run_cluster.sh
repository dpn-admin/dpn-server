#!/bin/bash
#
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
if [ ! -f config.ru ]; then
    echo "Run this script from the top-level Rails directory "
    echo "for the dpn-server project. E.g. script/run_cluster.sh"
    exit
fi

# Load fixture data for each node
echo "Loading fixture data for APTrust node"
RAILS_ENV=impersonate_aptrust bundle exec rake db:fixtures:load FIXTURES_DIR=integration/common
RAILS_ENV=impersonate_aptrust bundle exec rake db:fixtures:load FIXTURES_DIR=integration/aptrust

echo "Loading fixture data for Hathi node"
RAILS_ENV=impersonate_hathi bundle exec rake db:fixtures:load FIXTURES_DIR=integration/common
RAILS_ENV=impersonate_hathi bundle exec rake db:fixtures:load FIXTURES_DIR=integration/hathi

echo "Loading fixture data for Chronopolis node"
RAILS_ENV=impersonate_chron bundle exec rake db:fixtures:load FIXTURES_DIR=integration/common
RAILS_ENV=impersonate_chron bundle exec rake db:fixtures:load FIXTURES_DIR=integration/chron

echo "Loading fixture data for Stanford node"
RAILS_ENV=impersonate_sdr bundle exec rake db:fixtures:load FIXTURES_DIR=integration/common
RAILS_ENV=impersonate_sdr bundle exec rake db:fixtures:load FIXTURES_DIR=integration/sdr

echo "Loading fixture data for Texas node"
RAILS_ENV=impersonate_tdr bundle exec rake db:fixtures:load FIXTURES_DIR=integration/common
RAILS_ENV=impersonate_tdr bundle exec rake db:fixtures:load FIXTURES_DIR=integration/tdr

echo "Starting aptrust node on http://127.0.0.1:3001"
RAILS_ENV=impersonate_aptrust rails server -p 3001 -P tmp/pids/impersonate_aptrust.pid &
APTRUST_PID=$!

echo "Starting chron node on http://127.0.0.1:3002"
RAILS_ENV=impersonate_chron rails server -p 3002 -P tmp/pids/impersonate_chron.pid &
CHRON_PID=$!

echo "Starting hathi node on http://127.0.0.1:3003"
RAILS_ENV=impersonate_hathi rails server -p 3003 -P tmp/pids/impersonate_hathi.pid &
HATHI_PID=$!

echo "Starting sdr node on http://127.0.0.1:3004"
RAILS_ENV=impersonate_sdr rails server -p 3004 -P tmp/pids/impersonate_sdr.pid &
SDR_PID=$!

echo "Starting tdr node on http://127.0.0.1:3005"
RAILS_ENV=impersonate_tdr rails server -p 3005 -P tmp/pids/impersonate_tdr.pid &
TDR_PID=$!

echo "Use Ctrl-C to kill all the servers"

# Shut down all servers in response to CTRL-C.
# The django servers start child processes, and
# we want to make sure to kill them all.
# SIGINT doesn't work here, so we're using SIGTERM.
# http://stackoverflow.com/questions/392022/best-way-to-kill-all-child-processes
kill_all() {
    echo "Shutting down aptrust on http://127.0.0.1:3001"
    kill -SIGINT $APTRUST_PID

    echo "Shutting down chron on http://127.0.0.1:3002"
    kill -SIGINT $CHRON_PID

    echo "Shutting down hathi on http://127.0.0.1:3003"
    kill -SIGINT $HATHI_PID

    echo "Shutting down sdr on http://127.0.0.1:3004"
    kill -SIGINT $SDR_PID

    echo "Shutting down tdr on http://127.0.0.1:3005"
    kill -SIGINT $TDR_PID

    echo "Sent SIGINT to all Rails processes in the cluster"
}

trap kill_all SIGINT
wait $TDR_PID

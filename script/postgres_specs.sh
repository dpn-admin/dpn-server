#!/bin/bash

path=$(basename $(pwd))
[[ $path != 'dpn-server' ]] && echo 'Must run from "dpn-server" path' && exit

echo
echo "To initialize Postgres user and dbs, you must have admin access to run:"
echo "./script/postgres_init.sh"
echo

PGPASSWORD="dpnPass"

DB_DUMP_FILE=$1

cat << EOF > Gemfile.local
gem 'pg'
EOF

bundle install --quiet
bundle exec rake config

cat << EOF > config/database.yml
test:
  adapter: postgresql
  host: localhost
  database: dpn_test
  username: dpnAdmin
  password: $PGPASSWORD
EOF

export RAILS_ENV=test
bundle exec rake db:drop
bundle exec rake db:create
if [ "$DB_DUMP_FILE" != "" ]; then
    psql -h localhost -U dpnAdmin -d dpn_test < $DB_DUMP_FILE
fi
bundle exec rake db:migrate
bundle exec rake # rspec

echo
echo "To cleanup the Postgres tests, run:"
echo "./script/postgres_specs_cleanup.sh"
echo

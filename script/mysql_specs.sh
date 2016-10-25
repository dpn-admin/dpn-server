#!/bin/bash

path=$(basename $(pwd))
[[ $path != 'dpn-server' ]] && echo 'Must run from "dpn-server" path' && exit

echo
echo "To initialize MySQL db and user, you must have root user access and run:"
echo "mysql -u root -p < ./db/mysql_init.sql"
echo

DB_DUMP_FILE=$1

cat << EOF > Gemfile.local
gem 'mysql2'
EOF

bundle install --quiet
bundle exec rake config

cat << EOF > config/database.yml
test:
  adapter: mysql2
  encoding: utf8
  pool: 5
  timeout: 5000
  reconnect: true
  port: 3306
  username: dpnAdmin
  password: dpnPass
  database: dpn_test
EOF

export RAILS_ENV=test
bundle exec rake db:drop
bundle exec rake db:create
if [ "$DB_DUMP_FILE" != "" ]; then
    mysql -u dpnAdmin --password=dpnPass dpn_test < $DB_DUMP_FILE
fi
bundle exec rake db:migrate
bundle exec rake # rspec

echo
echo "To cleanup the MySQL tests, run:"
echo "./script/mysql_specs_cleanup.sh"
echo

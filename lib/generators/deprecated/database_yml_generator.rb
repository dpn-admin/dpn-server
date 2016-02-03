# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Deprecated
class DatabaseYamlGenerator < Rails::Generators::Base

  CONTENTS = <<-EOF
# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

default: &default
  adapter: sqlite3
  encoding: utf8
  pool: 5
  timeout: 5000
  reconnect: true
  port: 3306

development:
  <<: *default
  database: db/development.sqlite3

# The demo server at devops.aptrust.org.
demo:
  adapter: <%= ENV['DPN_DB_ADAPTER'] || 'postgresql' %>
  encoding: utf8
  database: <%= ENV['DPN_DB_NAME'] %>
  pool: 5
  username: <%= ENV['DPN_DB_USER'] %>
  password: <%= ENV['DPN_DB_PASSWORD'] %>
  host: <%= ENV['DPN_DB_HOSTNAME'] %>

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: db/test.sqlite3


production:
  <<: *default
  adapter: <%= ENV['DPN_DB_ADAPTER'] || 'mysql2' %>
  database: <%= ENV['DPN_DB'] %>
  username: <%= ENV['DPN_DB_USER'] %>
  host: <%= ENV['DPN_DB_HOSTNAME'] %>
  password: <%= ENV['DPN_DB_PASSWORD'] %>
  port: <%= ENV['DPN_DB_PORT'] || 3306 %>
  timeout: 2000
  reconnect: true

EOF

  def create
    create_file "config/database.yml", CONTENTS
  end
end
end
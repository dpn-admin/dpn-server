# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

source 'https://rubygems.org'

ruby '~> 2.3.0'

# ----------------------------------------------
# Include gems for your local environment here.
# e.g. gem "mysql2", group: :production
# ----------------------------------------------

if File.exist? 'Gemfile.local'
  eval_gemfile 'Gemfile.local'
end

gem 'rails', '~> 4.2'

gem 'active_scheduler', '~>0.3.0'
gem 'resque', '~>1.26.0'
gem 'resque-pool', '~>0.6.0'
gem 'resque-scheduler', '~>4.3.0'

gem 'cancan'
gem 'devise'

gem 'dpn-bagit', '~>0.3.0'
gem 'dpn-client', '~>2.0.0', git: 'https://github.com/dpn-admin/dpn-client.git'
gem 'dpn_swagger_engine'

gem 'bcrypt'
gem 'easy_cipher', '~>0.9.1'

gem 'json'
gem 'kaminari'

gem 'lograge'
gem 'logstash-event'

gem 'okcomputer' # app monitoring

gem 'rpairtree'
gem 'rsync', '~>1.0.9'

gem 'sdoc', '~> 0.4.0', group: :doc

# Note: These are not in a group block because doing
#       so breaks group block usage in Gemfile.local
gem 'sqlite3', group: [:development, :test]
gem 'app_version_tasks', group: [:development, :test]
gem 'byebug', group: [:development, :test]
gem 'codeclimate-test-reporter', group: [:development, :test]
gem 'fabrication', group: [:development, :test]
gem 'faker', group: [:development, :test]
gem 'pry', group: [:development, :test]
gem 'pry-doc', group: [:development, :test]
gem 'rspec-activejob', group: [:development, :test]
gem 'rspec-rails', group: [:development, :test]
gem 'rubocop', group: [:development, :test]
gem 'rubocop-rspec', group: [:development, :test]
gem 'simplecov', group: [:test]
gem 'web-console', '~> 2.1.3', group: [:development, :test]
gem 'yard', group: [:development, :test]

## Assets
# Use SCSS for stylesheets
gem 'sass-rails', group: [:assets]
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', group: [:assets]
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', group: [:assets]
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby, group: [:assets]

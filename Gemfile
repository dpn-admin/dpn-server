# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

source 'https://rubygems.org'

# ----------------------------------------------
# Include gems for your local environment here.
# e.g. gem "mysql2", group: :production
# ----------------------------------------------

if File.exists? "Gemfile.local"
  eval_gemfile "Gemfile.local"
end

ruby '~> 2.3'

gem 'rails', '~> 4.2.7'
gem 'active_scheduler', '~>0.3.0'
gem 'bcrypt'
gem 'cancan'
gem 'devise'
gem 'dpn-bagit', '~>0.3.0'
gem 'dpn-client', '~>2.0.0', git: 'https://github.com/dpn-admin/dpn-client.git'
gem 'easy_cipher', '~>0.9.1'
gem 'json'
gem 'kaminari'
gem 'lograge'
gem 'logstash-event'
gem 'resque', '~>1.26.0'
gem 'resque-pool', '~>0.6.0'
gem 'resque-scheduler', '~>4.3.0'
gem 'rpairtree'
gem 'rsync', '~>1.0.9'
gem 'therubyracer', platforms: :ruby


gem 'sdoc', '~> 0.4.0', group: :doc

# Note: These are not in a group block because doing 
#       so breaks group block usage in Gemfile.local
gem 'sqlite3', group: [:development, :test]
gem 'byebug', group: [:development, :test]
gem 'codeclimate-test-reporter', group: [:development, :test]
gem 'fabrication', group: [:development, :test]
gem 'faker', group: [:development, :test]
gem 'pry', group: [:development, :test]
gem 'pry-doc', group: [:development, :test]
gem 'rspec-activejob', group: [:development, :test]
gem 'rspec-rails', group: [:development, :test]
gem 'web-console', '~> 2.1.3', group: [:development, :test]
gem 'yard', group: [:development, :test]

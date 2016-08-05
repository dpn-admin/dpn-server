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

gem 'rails', '~> 4.2.5'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '~> 2.7'
gem 'jbuilder', '~> 2.0'
gem 'json'
gem 'bcrypt', '~> 3.1.7'
gem 'therubyracer', platforms: :ruby
gem 'kaminari'
gem 'resque'
gem 'resque-scheduler'
gem 'resque-pool'
gem 'active_scheduler'
gem 'rsync'
gem 'dpn-bagit', '~>0.3.0'
gem 'rpairtree'
gem 'easy_cipher', '~>0.9.1'
gem 'daemons'
gem 'rails_admin'
gem 'devise', '~> 3.5'
gem 'cancan'
gem 'dpn-client', :git => 'https://github.com/dpn-admin/dpn-client.git'


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

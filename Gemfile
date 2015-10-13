# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

source 'https://rubygems.org'

# The require line forces dotenv to be loaded before
# the other gems.
gem 'dotenv-rails', require: 'dotenv/rails-now'

gem 'rails', '~> 4.2.2'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jbuilder', '~> 2.0'
gem 'json'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'bcrypt', '~> 3.1.7'
gem 'therubyracer', platforms: :ruby
gem 'kaminari'
gem 'delayed_job_active_record'
gem 'rsync'
gem 'dpn-bagit', '~>0.3.0'
gem 'rpairtree'
gem 'easy_cipher', '~>0.9.1'
gem 'daemons'
gem 'rails_admin'
gem 'devise'
gem 'cancan'

group :production do
  gem 'mysql2'
end

group :development, :test do
  gem 'sqlite3'
  gem 'byebug'
  gem 'web-console', '~> 2.1.3'
  gem 'rspec-rails'
  gem 'fabrication'
  gem 'faker'
  gem 'rspec-activejob'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'codeclimate-test-reporter'
end

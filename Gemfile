# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

source 'https://rubygems.org'

# ----------------------------------------------
# Include gems for your local environment here.
# e.g. gem "mysql2", group: :production
# ----------------------------------------------

eval_gemfile 'Gemfile.local' if File.exist? 'Gemfile.local'

gem 'rails', '~> 4.2.5'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '~> 2.7'
gem 'jbuilder', '~> 2.0'
gem 'json'
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
gem 'devise', '~> 3.5'
gem 'cancan'

gem 'sdoc', '~> 0.4.0', group: :doc

group :development, :test do
  gem 'byebug'
  gem 'codeclimate-test-reporter'
  gem 'fabrication'
  gem 'faker'
  gem 'pry'
  gem 'pry-doc'
  gem 'rspec-activejob'
  gem 'rspec-rails'
  gem 'sqlite3'
  gem 'web-console', '~> 2.1.3'
  gem 'yard'
end

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically
# be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

# From https://github.com/sul-dlss/app_version_tasks
# A default configuration works for this application.
spec = Gem::Specification.find_by_name 'app_version_tasks'
load "#{spec.gem_dir}/lib/tasks/app_version_tasks.rake"
require 'app_version_tasks'

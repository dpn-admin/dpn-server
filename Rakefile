# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

desc 'Continuous integration task run on travis'
task ci: [:environment] do
  #Rake::Task['rubocop'].invoke
  if Rails.env.test?
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['spec'].invoke
  else
    system 'rake ci RAILS_ENV=test'
  end
end


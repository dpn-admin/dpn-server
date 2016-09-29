require 'resque/tasks'
require 'resque/scheduler/tasks'
require 'resque/pool/tasks'

task 'resque:setup' => :environment do
  require 'resque'
  require 'resque-scheduler'
  require 'resque/scheduler/server'
  Resque.redis.namespace = "dpn-server:#{Rails.env}"
end


task 'resque:pool:setup' do
  ActiveRecord::Base.connection.disconnect!
  Resque::Pool.after_prefork do |job|
    ActiveRecord::Base.establish_connection
    Resque.redis.client.reconnect
  end
end


task 'resque:prep_scheduler' => 'resque:setup' do
  require 'resque-scheduler'
  require 'active_scheduler'
end

task 'resque:scheduler' => ['resque:prep_scheduler', :environment]

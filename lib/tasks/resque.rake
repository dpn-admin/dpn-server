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

task 'resque:schedule' => 'resque:prep_scheduler' do
  Resque.schedule = ActiveScheduler::ResqueWrapper.wrap define_schedule[Rails.env]
end
task 'resque:scheduler' => 'resque:schedule'


def define_schedule
  schedule = {}

  if Node.table_exists?
    Node.all.pluck(:namespace).each do |namespace|
      schedule["sync_bags_from_#{namespace}"] = {
        description: "Sync bags from #{namespace}",
        every: ["10m", {first_in: "0m"} ],
        class: "Sync::BagJob",
        queue: "sync",
        args: namespace
      }

      schedule["sync_fixity_checks_from_#{namespace}"] = {
        description: "Sync fixity_checks from #{namespace}",
        every: ["10m", {first_in: "2m"} ],
        class: "Sync::FixityCheckJob",
        queue: "sync",
        args: namespace
      }

      schedule["sync_ingests_from_#{namespace}"] = {
        description: "Sync ingests from #{namespace}",
        every: ["10m", {first_in: "4m"} ],
        class: "Sync::IngestJob",
        queue: "sync",
        args: namespace
      }

      schedule["sync_members_from_#{namespace}"] = {
        description: "Sync members from #{namespace}",
        every: ["10m", {first_in: "6m"} ],
        class: "Sync::MemberJob",
        queue: "sync",
        args: namespace
      }

      schedule["sync_message_digests_from_#{namespace}"] = {
        description: "Sync message digests from #{namespace}",
        every: ["10m", {first_in: "8m"} ],
        class: "Sync::MessageDigestJob",
        queue: "sync",
        args: namespace
      }

      schedule["sync_replication_transfers_from_#{namespace}"] = {
        description: "Sync replication transfers from #{namespace}",
        every: ["5m", {first_in: "0m"} ],
        class: "Sync::ReplicationTransferJob",
        queue: "sync",
        args: namespace
      }

      schedule["sync_restore_transfers_from_#{namespace}"] = {
        description: "Sync restore transfers from #{namespace}",
        every: ["5m", {first_in: "150s"} ],
        class: "Sync::RestoreTransferJob",
        queue: "sync",
        args: namespace
      }

      schedule["sync_nodes_from_#{namespace}"] = {
        description: "Sync nodes from #{namespace}",
        every: ["1h", {first_in: "0m"} ],
        class: "Sync::NodeJob",
        queue: "sync",
        args: namespace
      }
    end
  end

  schedule_per_env = {
    "test" => {},
    "development" => {
      "test_recurring_job" => {
        description: "A fake job to see if something will appear",
        every: ["5m", {first_in: "1m"} ],
        class: "Sync::NodeJob",
        queue: "sync",
        args: Rails.configuration.local_namespace
      }
    },
    "production" => schedule
  }

  return schedule_per_env
end

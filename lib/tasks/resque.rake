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

task 'resque:schedule' => ['resque:prep_scheduler', :environment] do
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
        class: Client::Sync::Job.to_s,
        queue: "sync",
        args: [
          "sync_bags_#{namespace}", namespace,
          Client::Sync::QueryBuilder::Bag.to_s,
          BagAdapter.to_s, Bag.to_s
        ]
      }

      schedule["sync_fixity_checks_from_#{namespace}"] = {
        description: "Sync fixity_checks from #{namespace}",
        every: ["10m", {first_in: "2m"} ],
        class: Client::Sync::Job.to_s,
        queue: "sync",
        args: [
          "sync_fixity_checks_#{namespace}", namespace,
          Client::Sync::QueryBuilder::FixityCheck.to_s,
          FixityCheckAdapter.to_s, FixityCheck.to_s
        ]
      }

      schedule["sync_ingests_from_#{namespace}"] = {
        description: "Sync ingests from #{namespace}",
        every: ["10m", {first_in: "4m"} ],
        class: Client::Sync::Job.to_s,
        queue: "sync",
        args: [
          "sync_ingests_#{namespace}", namespace,
          Client::Sync::QueryBuilder::Ingest.to_s,
          IngestAdapter.to_s, Ingest.to_s
        ]
      }

      schedule["sync_members_from_#{namespace}"] = {
        description: "Sync members from #{namespace}",
        every: ["10m", {first_in: "6m"} ],
        class: Client::Sync::Job.to_s,
        queue: "sync",
        args: [
          "sync_members_#{namespace}", namespace,
          Client::Sync::QueryBuilder::Member.to_s,
          MemberAdapter.to_s, Member.to_s
        ]
      }

      schedule["sync_message_digests_from_#{namespace}"] = {
        description: "Sync message digests from #{namespace}",
        every: ["10m", {first_in: "8m"} ],
        class: Client::Sync::Job.to_s,
        queue: "sync",
        args: [
          "sync_message_digests_#{namespace}", namespace,
          Client::Sync::QueryBuilder::MessageDigest.to_s,
          MessageDigestAdapter.to_s, MessageDigest.to_s
        ]
      }

      schedule["sync_replication_transfers_from_#{namespace}"] = {
        description: "Sync replication transfers from #{namespace}",
        every: ["5m", {first_in: "0m"} ],
        class: Client::Sync::Job.to_s,
        queue: "sync",
        args: [
          "sync_replications_#{namespace}", namespace,
          Client::Sync::QueryBuilder::ReplicationTransfer.to_s,
          ReplicationTransferAdapter.to_s, ReplicationTransfer.to_s
        ]
      }

      schedule["sync_restore_transfers_from_#{namespace}"] = {
        description: "Sync restore transfers from #{namespace}",
        every: ["5m", {first_in: "150s"} ],
        class: Client::Sync::Job.to_s,
        queue: "sync",
        args: [
          "sync_restores_#{namespace}", namespace,
          Client::Sync::QueryBuilder::RestoreTransfer.to_s,
          RestoreTransferAdapter.to_s, RestoreTransfer.to_s
        ]
      }

      schedule["sync_node_from_#{namespace}"] = {
        description: "Sync nodes from #{namespace}",
        every: ["1h", {first_in: "0m"} ],
        class: Client::Sync::Job.to_s,
        queue: "sync",
        args: [
          "sync_node_#{namespace}", namespace,
          Client::Sync::QueryBuilder::Node.to_s,
          NodeAdapter.to_s, Node.to_s
        ]
      }
    end
  end

  schedule_per_env = {
    "test" => {},
    "development" => {
      "test_recurring_job" => {
        description: "A fake job to see if something will appear",
        every: ["5m", {first_in: "10h"} ],
        class: Client::Sync::Job.to_s,
        queue: "sync",
        args: [
          "test_recurring_sync_job", Rails.configuration.local_namespace,
          Client::Sync::QueryBuilder::Node.to_s,
          NodeAdapter.to_s, Node.to_s
        ]
      }
    },
    "production" => schedule
  }

  return schedule_per_env
end

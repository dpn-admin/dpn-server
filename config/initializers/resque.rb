# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

# We check if resque is enabled; if so, we initialize it.

module ResqueInit
  class << self
    def init!
      if resque_enabled?
        init_resque
      end
    end

    def resque_enabled?
      dpn_config_file = File.join Rails.root, "config", "dpn.yml"
      dpn_config = YAML.load(ERB.new(IO.read(dpn_config_file)).result)[Rails.env]
      dpn_config["queue_adapter"] == :resque
    end

    def init_resque
      require 'resque'
      rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
      rails_env = ENV['RAILS_ENV'] || 'development'

      resque_config = YAML.load_file(File.join rails_root, '/config/resque.yml')
      Resque.redis = resque_config[rails_env]
      Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
      Resque.inline = Rails.env.test?
      Resque.redis.namespace = "dpn-server:#{Rails.env}"

      require 'resque-scheduler'
      require 'resque/scheduler/server'
      Resque.schedule = ActiveScheduler::ResqueWrapper.wrap schedule(rails_env)
    end

    def schedule(env)
      case env
      when "test"
        test_schedule
      when "development"
        dev_schedule
      when "production"
        prod_schedule
      else
        test_schedule
      end
    end

    def test_schedule
      {}
    end

    def dev_schedule
      {
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
      }
    end

    def prod_schedule
    schedule = {}

    if Node.table_exists?
      other_nodes = Node.where.not(namespace: Rails.configuration.local_namespace)
      other_nodes.pluck(:namespace).each do |namespace|
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

    return schedule
    end
  end
end


ResqueInit.init!
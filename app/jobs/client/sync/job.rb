# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Client
  module Sync
    class Job < ActiveJob::Base
      queue_as :sync

      # @param [String] name Name for this job
      # @param [String] namespace
      def last_success_manager(name, namespace)
        LastSuccessManager.new "#{name}_#{namespace}"
      end


      # @param [Class] klass The query builder's class
      def query_builder(klass, namespace)
        klass.new(Rails.configuration.local_namespace, namespace)
      end


      # @param [Class] model_class Class of the model we're syncing
      def creator_updater(model_class)
        CreatorUpdater.new(model_class)
      end

      # @param [Client::Sync::LastSuccessManager] last_success_manager
      # @param [Client::RemoteClient] remote_client
      # @param [Client::Sync::QueryBuilder] query_builder Instance of subclass of QueryBuilder
      # @param [Class] adapter_class The class of the adapter.  Must respond to
      #   ::from_public and #to_model_hash
      # @param [Client::Sync::CreatorUpdater]
      def sync(last_success_manager, remote_client, query_builder, adapter_class, updater)
        last_success_manager.manage do |last_success, _|
          query_builder.queries(last_success).each do |query|
            remote_client.execute(query) do |response|
              raise RuntimeError, response.body unless response.success?
              updater.update!(adapter_class.from_public(response.body).to_model_hash)
            end
          end
        end
      end


      # This job handles synchronizing a specific type of resource, locally
      # represented as a model class, from the remote node.  It handles lookup
      # of the last time it successfully ran, and will automatically be requeued
      # should it fail.
      #
      # @example Normal creation will follow this pattern:
      #   Client::Sync::Job.perform_later(
      #     "synchronize_bags",
      #     "hathi",
      #     Client::Sync::QueryBuilder::Bag.to_s,
      #     BagAdapter.to_s,
      #     Bag.to_s
      #   )
      #
      # The reason the method signature calls for these odd types is due to
      # the limitations in ActiveJob's ability to serialize arguments.
      # @see ActiveJob::Arguments#serialize
      #
      # @param [String] name A unique name for this job; this defines the RunTime
      #   that will be used.
      # @param [String] namespace Namespace of the remote node
      # @param [String] query_builder_class The result of calling #to_s on the
      #   QueryBuilder subclass, e.g. QueryBuilder::Bag.to_s
      # @param [String] adapter_class The result of calling #to_s on the adapter
      #   subclass, e.g. BagAdapter.to_s
      # @param [String] model_class The result of calling #to_s on the
      #   model class, e.g. Bag.to_s
      def perform(name, namespace, query_builder_class, adapter_class, model_class)
        sync(
          last_success_manager(name, namespace),
          remote_client(namespace),
          query_builder(query_builder_class.classify, namespace),
          adapter_class.classify,
          model_class.classify
        )
      end

    end
  end
end

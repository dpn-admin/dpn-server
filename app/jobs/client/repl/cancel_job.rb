# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl
    class CancelJob < ActiveJob::Base
      include Common
      queue_as :repl

      # @param [Client::RemoteClient] remote_client
      # @param [Client::Query] get_query Query to get their record
      # @param [Client::Query] cancel_query Query to cancel their record.
      def cancel(remote_client, get_query, cancel_query)
        remote_client.execute get_query do |response|
          raise RuntimeError, response.body unless response.success?
          return if response.body[:cancelled]
        end
        remote_client.execute cancel_query do |response|
          raise RuntimeError, response.body unless response.success?
        end
      end


      # @see #perform for the arguments this takes
      # @see #cancel for the return values
      def normalize_args(record, namespace, get_query_type, cancel_query_type, adapter_class)
        return [
          remote_client(namespace),
          query(get_query_type.to_sym, {}),
          query(cancel_query_type.to_sym, body(record, adapter_class.constantize))
        ]
      end


      # Cancels the record on a remote node.  Does nothing if
      # their record is already cancelled.
      #
      # @example Normal creation will follow this pattern:
      #   Client::Repl::CancelJob.peform_later(
      #     replication_instance,
      #     "hathi",
      #     "replicate",
      #     "update_replication",
      #     ReplicationTransferAdapter.to_s
      #   )
      #
      # The reason the method signature calls for these odd types is due to
      # the limitations in ActiveJob's ability to serialize arguments.
      # @see ActiveJob::Arguments#serialize
      #
      # @param [ActiveRecord::Base] record
      # @param [String] namespace
      # @param [String] get_query_type Type of query as defined by
      #   DPN::Client
      # @param [String] cancel_query_type Type of query as defined by
      #   DPN::Client
      # @param [String] adapter_class The adapter class as a string,
      #   i.e. the output of FooAdapter.to_s
      def perform(record, namespace, get_query_type, cancel_query_type, adapter_class)
        cancel *normalize_args(record, namespace, get_query_type, cancel_query_type, adapter_class)
      end


    end
  end
end

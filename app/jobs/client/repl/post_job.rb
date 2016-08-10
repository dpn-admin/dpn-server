# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Repl
    class PostJob < ActiveJob::Base
      include Common
      queue_as :repl

      # @param [Client::RemoteClient] remote_client
      # @param [ActiveRecord::Base] record The local record (via globalid)to update.
      # @param [Client::Query] query
      def post(remote_client, record, query)
        return if record.respond_to?(:cancelled?) && record.cancelled?
        remote_client.execute query do |response|
          raise RuntimeError, response.body unless response.success?
        end
      end


      # @see #perform for the arguments this takes
      # @see #cancel for the return values
      def normalize_args(record, namespace, query_type, adapter_class)
        return [
          remote_client(namespace),
          record,
          query(query_type.to_sym, body(record, adapter_class.constantize))
        ]
      end


      # Updates a record on a remote node.  If the record responds to #cancelled?,
      #   only update the remote record if the local one is not cancelled.
      #
      # @example Normal creation will follow this pattern:
      #   Client::Repl::PostJob.peform_later(
      #     bag_instance,
      #     "hathi",
      #     "update_bag",
      #     BagAdapter.to_s
      #   )
      #
      # The reason the method signature calls for these odd types is due to
      # the limitations in ActiveJob's ability to serialize arguments.
      # @see ActiveJob::Arguments#serialize
      #
      # @param [ActiveRecord::Base] record
      # @param [String] namespace Namespace of the remote node.
      # @param [String] query_type Type of query as defined by
      #   DPN::Client
      # @param [String] adapter_class The adapter class as a string,
      #   i.e. the output of FooAdapter.to_s
      def perform(record, namespace, query_type, adapter_class)
        post *normalize_args(record, namespace, query_type, adapter_class)
      end



    end
  end
end

# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Client
  module Common

    # @param [String] namespace
    # @return [Client::RemoteClient]
    def remote_client(namespace)
      node = Node.find_by_namespace!(namespace)
      RemoteClient.new(node.api_root, node.auth_credential, Rails.logger)
    end


    # @param [ActiveRecord::Base] record
    # @param [Class] adapter_class
    # @return [Hash]
    def body(record, adapter_class)
      adapter_class.from_model(record).to_public_hash
    end


    # @param [Symbol] method Type of query as defined by
    #   DPN::Client
    # @param [Hash] body Body of the query, usually the output
    #   of an adapter's to_public_hash method.
    # @return [Client::Query]
    def query(method, body)
      Query.new method, body
    end


  end
end
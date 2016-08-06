# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Sync
  
  # A client connection to a remote node.
  class RemoteClient
    
    # Create a RemoteClient instance.  The connection is NOT
    # initialized until you issue a query.
    # @param [String] api_root The url of the remote node's api root
    # @param [String] auth_credential The token to authenticate with 
    #   the remote node.
    # @param [Logger] logger A logger, e.g. the Rails logger.
    def initialize(api_root, auth_credential, logger = Rails.logger)
      @api_root = api_root
      @auth_credential = auth_credential
      @logger = logger
    end
    
    
    # Execute the given query.
    # @param [Query] query A Query instance.
    # @yield [DPN::Client::Response] Yields each record within the response
    #   to the passed block.
    def execute(query, &block)
      client.public_send(query.type, query.params) do |response|
        yield response
      end
    end
    
    private
    
    def client
      @client ||= DPN::Client.client.configure do |c|
        c.api_root = @api_root
        c.auth_token = @auth_credential
        c.logger = @logger
      end
    end
    
    
  end
end  
  
  

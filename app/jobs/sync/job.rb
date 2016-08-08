# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Sync
  class Job < ActiveJob::Base
    queue_as :sync
    
    # @param [LastSuccessManager] last_success_manager
    # @param [RemoteClient] remote_client
    # @param [QueryBuilder] query_builder Instance of subclass of QueryBuilder
    # @param [Class] adapter_class The class of the adapter.  Must respond to 
    #   ::from_public and #to_model_hash
    # @param [CreatorUpdater]
    def perform(last_success_manager, remote_client, query_builder, adapter_class, updater)
      last_success_manager.manage do |last_success, _|
        query_builder.queries(last_success).each do |query|
          remote_client.execute(query) do |response|
            raise RuntimeError, response.body unless response.success?
            updater.update!(adapter_class.from_public(response.body).to_model_hash)
          end
        end
      end

    end
  end
end

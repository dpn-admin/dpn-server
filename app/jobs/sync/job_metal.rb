# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Sync
  class JobMetal < Job
    def perform(name, namespace, query_builder_class, adapter_class, model_class)
      last_success_manager = LastSuccessManager.new "#{name}_#{namespace}"
      node = Node.find_by_namespace!(namespace)
      remote_client = RemoteClient.new(node.api_root, node.auth_credential, Rails.logger)
      query_builder = query_builder_class.new(Rails.configuration.local_namespace, namespace)
      creator_updater = CreatorUpdater.new(model_class)
      super(last_success_manager, remote_client, query_builder, adapter_class, creator_updater)
    end
  end
end
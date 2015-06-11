require "frequent_apple"
# Job to get the latest version of a target non-local node
# from the implicated node, and copy the update to the
# local node.
class FrequentApple::SyncNodeJob < ActiveJob::Base
  queue_as :default
  include Remote

  # @param target_namespace [String] Namespace of the node to operate on.
  # @param local_node_namespace [String] The namespace of the node to
  # use as the local node. This will make changes via that node's api.
  def perform(target_namespace, local_node_namespace = Rails.configuration.local_namespace)
    if target_namespace != local_node_namespace
      response = remote_client.get("/node/#{target_namespace}")
      raise RuntimeError, response.body unless response.ok?
      local_client.put("/node/#{target_namespace}", response.body)
    end
  end
end




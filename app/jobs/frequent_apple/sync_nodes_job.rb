require "frequent_apple"
# Job to get the latest version of each non-local node
# from the implicated node, and copy the update to the
# local node.
class FrequentApple::SyncNodesJob < ActiveJob::Base
  queue_as :default

  # @param local_node_namespace [String] The namespace of the node to
  # use as the local node. This will make changes via that node's api.
  def perform(local_node_namespace = Rails.configuration.local_node)
    local_node = Node.find_by_namespace!(local_node_namespace)
    client = FrequentApple.client(local_node.api_root, local_node.auth_credential)
    FrequentApple.get_nodes(client).each do |known_node|
      if known_node[:namespace] != local_node.namespace
        begin
          their_node = self.get_node(known_node[:api_root], known_node[:namespace])
          unless client.post("/node", their_node.to_json).ok?
            client.put("/node/#{known_node[:namespace]}", their_node.to_json)
          end
        rescue HTTPClient::TimeoutError, SocketError, Errno::ECONNREFUSED
          next
        end
      end
    end
  end

  protected
  # Get the latest json body of a node
  # @param client [HTTPClient]
  # @param api_root [String] The api root of the target node.
  # @param _namespace [String] The namespace of the target node.
  # @return [Hash] The json body of the target node.
  def get_node(api_root, _namespace)
    auth_cred = Node.find_by_namespace!(_namespace).auth_credential
    client_for_their_node = FrequentApple.client(api_root, auth_cred)
    response = client_for_their_node.get("/node/#{_namespace}")
    if response.ok?
      return JSON.parse(response.body, symbolize_names: true)
    else
      return {}
    end
  end

end




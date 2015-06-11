require "json"
require "frequent_apple"

class CreateBagMgrRequestJob < ActiveJob::Base
  queue_as :internal

  def perform(replication_transfer, local_namespace =  Rails.configuration.local_namespace)
    local_node = Node.find_by_namespace!(local_namespace)
    client = FrequentApple.client(local_node.api_root, local_node.auth_credential)

    post_body = {
        source_location: replication_transfer.link,
        status: :requested,
        fixity: nil,
        validity: nil,
        cancelled: false
    }
    response = client.post("/bag_mgr/requests", post_body.to_json)
    raise RuntimeError, response.body unless response.ok?

    if response.status == 201
      response = client.get(response.header["location"])
    end

    bag_mgr_request = JSON.parse(response.body, symbolize_names: true)
    replication_transfer.bag_mgr_request_id = Integer(bag_mgr_request[:id])
    replication_transfer.save!
  end
end

require "frequent_apple"
require "json"

# Job to synchronize bag_mgr/request
# info to the corresponding replication
# transfer.
class FrequentApple::UpdateReplicationStatusJob < ActiveJob::Base
  queue_as :external
  include Remote

  def perform(target_namespace, local_node_namespace = Rails.configuration.local_namespace)
    transfers = ReplicationTransfer
        .joins(:replication_status)
        .where(replication_statuses: { name: [:requested, :received, :confirmed]})
        .joins("INNER JOIN #{Node.table_name} AS to_node ON to_node.id = #{ReplicationTransfer.table_name}.to_node_id")
        .where(to_node: {namespace: local_node_namespace})
        .joins("INNER JOIN #{Node.table_name} AS from_node ON from_node.id = #{ReplicationTransfer.table_name}.from_node_id")
        .where(from_node: {namespace: target_namespace})
        .where.not(bag_mgr_request_id: nil)

    transfers.each do |transfer|
      bag_mgr_request = JSON.parse(local_client.get("/bag_mgr/#{transfer.bag_mgr_request_id}").body, symbolize_names: true)
      new_transfer = ApiV1::ReplicationTransferPresenter.new(transfer).to_hash

      new_transfer[:fixity_value] ||= bag_mgr_request[:fixity]
      new_transfer[:bag_valid] ||= bag_mgr_request[:validity]

      if bag_mgr_request[:cancelled] == true
        new_transfer[:status] = "cancelled"
      elsif bag_mgr_request[:status] == "preserved"
        new_transfer[:status] = "stored"
      elsif bag_mgr_request[:status] == "rejected"
        new_transfer[:status] = "rejected"
      elsif bag_mgr_request[:status] == "unpacked"
        if bag_mgr_request[:fixity].blank? == false && bag_mgr_request[:validity] != nil
          if bag_mgr_request[:validity] == true
            new_transfer[:status] = "received"
          else
            new_transfer[:status] = "cancelled"
          end
        end
      end

      if new_transfer[:status] != transfer.replication_status.name
        [remote_client, local_client].each do |client|
          response = client.put("/replicate/#{new_transfer[:replication_id]}", new_transfer.to_json)
          raise RuntimeError, response.body unless response.ok?
        end
      end

    end

  end

end
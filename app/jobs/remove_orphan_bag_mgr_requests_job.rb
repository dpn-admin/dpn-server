class RemoveOrphanBagmanRequestsJob < ActiveJob::Base
  queue_as :internal

  def perform
    orphaned_bag_man_requests = BagManRequest
      .joins(replication_transfer: :replication_status)
      .where(to_node: Node.local_node!)
      .where(replication_statuses: {name: [:cancelled, :stored, :rejected]})

    orphaned_bag_man_requests.each do |orphaned_bag_man_request|
      orphaned_bag_man_request.destroy
    end
  end
end

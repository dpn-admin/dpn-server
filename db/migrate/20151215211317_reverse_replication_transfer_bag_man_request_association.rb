class ReverseReplicationTransferBagManRequestAssociation < ActiveRecord::Migration
  def change
    remove_column :replication_transfers, :bag_man_request_id, :integer
    add_column :bag_man_requests, :replication_transfer_id, :integer, null: true
    add_foreign_key :bag_man_requests, :replication_transfers,
      column: :replication_transfer_id,
      on_delete: :cascade,
      on_update: :cascade
  end
end

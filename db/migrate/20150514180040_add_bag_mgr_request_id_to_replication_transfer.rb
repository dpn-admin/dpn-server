class AddBagMgrRequestIdToReplicationTransfer < ActiveRecord::Migration
  def change
    add_column :replication_transfers, :bag_mgr_request_id, :integer, null: true, default: nil
    add_index :replication_transfers, :bag_mgr_request_id, unique: true
  end
end

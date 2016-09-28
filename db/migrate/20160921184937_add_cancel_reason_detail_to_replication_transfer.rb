class AddCancelReasonDetailToReplicationTransfer < ActiveRecord::Migration
  def change
    add_column :replication_transfers, :cancel_reason_detail, :string, limit: 255, null: true
  end
end

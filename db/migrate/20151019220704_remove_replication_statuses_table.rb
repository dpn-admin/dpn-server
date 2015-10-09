class RemoveReplicationStatusesTable < ActiveRecord::Migration
  def change
    remove_reference :replication_transfers, :replication_status, foreign_key: true
    drop_table :replication_statuses
    add_column :replication_transfers, :status, :integer, default: 0, null: false
  end
end

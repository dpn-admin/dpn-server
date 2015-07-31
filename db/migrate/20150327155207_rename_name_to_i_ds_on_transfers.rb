class RenameNameToIDsOnTransfers < ActiveRecord::Migration
  def change
    remove_index :replication_transfers, column: :name
    rename_column :replication_transfers, :name, :replication_id
    add_index :replication_transfers, :replication_id, unique: true

    remove_index :restore_transfers, column: :name
    rename_column :restore_transfers, :name, :restore_id
    add_index :restore_transfers, :restore_id, unique: true
  end
end

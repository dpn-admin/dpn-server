class MakeIndexesUnique < ActiveRecord::Migration
  def change
    remove_index :nodes, :api_root
    add_index :nodes, :api_root, unique: true

    remove_index :replication_transfers, :name
    add_index :replication_transfers, :name, unique: true

    remove_index :restore_transfers, :name
    add_index :restore_transfers, :name, unique: true
  end
end

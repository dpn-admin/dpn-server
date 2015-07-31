class AddNameToReplicationTransfers < ActiveRecord::Migration
  def change
    change_table :replication_transfers do |t|
      t.string :name
      t.index :name
    end
  end
end

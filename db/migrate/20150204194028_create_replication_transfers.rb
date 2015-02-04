class CreateReplicationTransfers < ActiveRecord::Migration
  def change
    create_table :replication_transfers do |t|
      t.references :bag, null: false
      t.integer :from_node_id, null: false
      t.integer :to_node_id, null: false
      t.references :replication_status, null: false
      t.references :protocol, null: false
      t.string :link, null: false
      t.boolean :bag_valid
      t.references :fixity_alg, null: false
      t.text :fixity_nonce
      t.string :fixity_value
      t.boolean :fixity_accept
      t.timestamps null: false
    end
  end
end

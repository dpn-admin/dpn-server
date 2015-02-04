class CreateReplicatingNodes < ActiveRecord::Migration
  def change
    create_table :replicating_nodes do |t|
      t.references :node, null: false
      t.references :bag, null: false
      t.timestamps null: false
    end
    add_index :replicating_nodes, [:node_id, :bag_id], unique: true
  end
end

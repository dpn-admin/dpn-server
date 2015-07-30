class CreateRestoreTransfers < ActiveRecord::Migration
  def change
    create_table :restore_transfers do |t|
      t.references :bag, null: false
      t.integer :from_node_id, null: false
      t.integer :to_node_id, null: false
      t.references :restore_status, null: false
      t.references :protocol, null: false
      t.string :link, null: false
      t.timestamps null: false
    end
  end
end

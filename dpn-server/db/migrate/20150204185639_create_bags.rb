class CreateBags < ActiveRecord::Migration
  def change
    create_table :bags do |t|
      t.string :uuid
      t.string :local_id
      t.integer :size
      t.integer :version, null: false
      t.integer :first_version_bag_id, null: false
      t.integer :original_node_id, null: false
      t.integer :admin_node_id, null: false
      t.string :type
      t.timestamps null: false
    end
    add_index :bags, :uuid, unique: true
  end
end


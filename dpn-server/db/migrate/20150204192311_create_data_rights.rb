class CreateDataRights < ActiveRecord::Migration
  def change
    create_table :data_rights do |t|
      t.integer :data_bag_id, null: false
      t.integer :rights_bag_id, null: false
      t.timestamps null: false
    end
    add_index :data_rights, [:data_bag_id, :rights_bag_id], unique: true
  end
end

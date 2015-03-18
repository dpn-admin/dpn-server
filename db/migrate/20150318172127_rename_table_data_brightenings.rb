class RenameTableDataBrightenings < ActiveRecord::Migration
  def change
    drop_table :data_brightenings

    create_table :data_interpretive do |t|
      t.integer :data_bag_id, null: false
      t.integer :interpretive_bag_id, null: false
      t.timestamps null: false
    end

    add_index :data_interpretive, [:data_bag_id, :interpretive_bag_id], unique: true
  end
end


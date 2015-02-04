class CreateDataBrightening < ActiveRecord::Migration
  def change
    create_table :data_brightenings do |t|
      t.integer :data_bag_id, null: false
      t.integer :brightening_bag_id, null: false
      t.timestamps null: false
    end
    add_index :data_brightenings, [:data_bag_id, :brightening_bag_id], unique: true
  end
end

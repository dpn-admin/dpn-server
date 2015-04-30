class CreateBagManagerRequests < ActiveRecord::Migration
  def change
    create_table :bag_manager_requests do |t|
      t.string :source_location, null: false
      t.string :preservation_location
      t.integer :status, default: 0
      t.string :fixity, default: nil
      t.boolean :bag_valid, default: nil
      t.timestamps null: false
    end
  end
end

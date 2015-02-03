class CreateStorageRegions < ActiveRecord::Migration
  def change
    create_table :storage_regions do |t|
      t.string :name, null: false
      t.string :city, null: false
      t.string :country, null: false

      t.timestamps null: false
    end
    add_index :storage_regions, :name, unique: true
  end
end

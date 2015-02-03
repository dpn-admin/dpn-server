class CreateStorageRegions < ActiveRecord::Migration
  def change
    create_table :storage_regions do |t|
      t.string :nickname
      t.string :city
      t.string :country

      t.timestamps null: false
    end
  end
end

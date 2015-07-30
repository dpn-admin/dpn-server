class CreateStorageTypes < ActiveRecord::Migration
  def change
    create_table :storage_types do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :storage_types, :name, unique: true
  end
end

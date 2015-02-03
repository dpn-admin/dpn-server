class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :namespace, null: false
      t.string :readable_name, null: false
      t.string :ssh_pubkey
      t.references :storage_region
      t.references :storage_type

      t.timestamps null: false
    end
    add_index :nodes, :namespace, unique: true
  end
end

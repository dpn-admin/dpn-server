class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :namespace
      t.string :readable_name
      t.string :ssh_pubkey

      t.timestamps null: false
    end
    add_index :nodes, :namespace, unique: true
  end
end

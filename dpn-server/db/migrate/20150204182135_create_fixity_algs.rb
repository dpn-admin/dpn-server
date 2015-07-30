class CreateFixityAlgs < ActiveRecord::Migration
  def change
    create_table :fixity_algs do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :fixity_algs, :name, unique: true
  end
end

class CreateFixityAlgorithms < ActiveRecord::Migration
  def change
    create_table :fixity_algorithms do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :fixity_algorithms, :name, unique: true
  end
end

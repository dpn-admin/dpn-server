class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :protocols, :name, unique: true
  end
end

# Yo license information

class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :uuid, null: false
      t.string :name, null: false
      t.string :email
      t.timestamps null: false
    end
    add_index :members, :uuid, unique: true
  end
end

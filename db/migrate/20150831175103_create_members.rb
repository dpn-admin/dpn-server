# Yo license information

class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :uuid
      t.string :name
      t.string :email
    end
    add_index :members, :uuid, unique: true
  end
end

class AddFieldToNode < ActiveRecord::Migration
  def change
    change_table :nodes do |t|
      t.string :api_root
      t.index :api_root
    end
  end
end

class AddNameToRestoreTransfers < ActiveRecord::Migration
  def change
    change_table :restore_transfers do |t|
      t.string :name
      t.index :name
    end
  end
end

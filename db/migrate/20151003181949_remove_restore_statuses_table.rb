class RemoveRestoreStatusesTable < ActiveRecord::Migration
  def change
    remove_reference :restore_transfers, :restore_status, foreign_key: true
    drop_table :restore_statuses
    add_column :restore_transfers, :status, :integer, default: 0, null: false
  end

end

class ChangeTableRestoreTransfers < ActiveRecord::Migration
  def change
    change_column_null :restore_transfers, :restore_id, false
    remove_column :restore_transfers, :status, :integer, default: 0, null: false
    add_column :restore_transfers, :accepted,   :boolean, default: false, null: false
    add_column :restore_transfers, :finished,   :boolean, default: false, null: false
    add_column :restore_transfers, :cancelled,  :boolean, default: false, null: false
    add_column :restore_transfers, :cancel_reason, :string, null: true
  end
end

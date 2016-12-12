class AddCancelReasonDetailToRestoreTransfer < ActiveRecord::Migration
  def change
    add_column :restore_transfers, :cancel_reason_detail, :string, limit: 255, null: true
  end
end

class FixCancelReasonAndCancelReasonDetailTypes < ActiveRecord::Migration
  def up
    change_column :replication_transfers, :cancel_reason, :string
    change_column :replication_transfers, :cancel_reason_detail, :text, limit: nil
    change_column :restore_transfers, :cancel_reason, :string
    change_column :restore_transfers, :cancel_reason_detail, :text, limit: nil
  end
  def down
    change_column :replication_transfers, :cancel_reason_detail, :string, limit: 255
    change_column :replication_transfers, :cancel_reason, :text
    change_column :restore_transfers, :cancel_reason_detail, :string, limit: 255
    change_column :restore_transfers, :cancel_reason, :text
  end
end

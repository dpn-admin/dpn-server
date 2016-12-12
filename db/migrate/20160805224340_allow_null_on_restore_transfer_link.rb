class AllowNullOnRestoreTransferLink < ActiveRecord::Migration
  def change
    change_column_null :restore_transfers, :link, true
  end
end

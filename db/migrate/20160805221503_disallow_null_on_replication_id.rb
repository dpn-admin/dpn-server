class DisallowNullOnReplicationId < ActiveRecord::Migration
  def change
    change_column_null :replication_transfers, :replication_id, false
  end
end

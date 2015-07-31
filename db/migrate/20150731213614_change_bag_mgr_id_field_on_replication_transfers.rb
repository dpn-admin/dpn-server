class ChangeBagMgrIdFieldOnReplicationTransfers < ActiveRecord::Migration
  def change
    change_table :replication_transfers do |t|
      t.rename :bag_mgr_request_id, :bag_man_request_id
    end
  end
end

# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class AddBagMgrRequestIdToReplicationTransfer < ActiveRecord::Migration
  def change
    add_column :replication_transfers, :bag_mgr_request_id, :integer, null: true, default: nil
    add_index :replication_transfers, :bag_mgr_request_id, unique: true
  end
end

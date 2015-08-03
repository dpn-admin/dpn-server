# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ChangeBagMgrIdFieldOnReplicationTransfers < ActiveRecord::Migration
  def change
    change_table :replication_transfers do |t|
      t.rename :bag_mgr_request_id, :bag_man_request_id
    end
  end
end

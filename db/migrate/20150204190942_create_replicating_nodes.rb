# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class CreateReplicatingNodes < ActiveRecord::Migration
  def change
    create_table :replicating_nodes do |t|
      t.references :node, null: false
      t.references :bag, null: false
      t.timestamps null: false
    end
    add_index :replicating_nodes, [:node_id, :bag_id], unique: true
  end
end

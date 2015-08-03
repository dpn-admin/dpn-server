# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class RemoveTimestampsFromReplicatingNodes < ActiveRecord::Migration
  def change
    remove_column :replicating_nodes, :created_at, :string
    remove_column :replicating_nodes, :updated_at, :string
  end
end

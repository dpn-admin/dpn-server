# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class BagNode < ActiveRecord::Base
  self.table_name = "replicating_nodes"
  
  belongs_to :bag,  inverse_of: :bag_nodes, touch: true
  belongs_to :node, inverse_of: :bag_nodes, touch: true

  validates_uniqueness_of :bag_id, scope: :node_id
end

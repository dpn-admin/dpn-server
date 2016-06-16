# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class NodeIngest < ActiveRecord::Base
  self.table_name = "nodes_ingests"

  belongs_to :ingest, inverse_of: :node_ingests, touch: true
  belongs_to :node,   inverse_of: :node_ingests, touch: false

  validates_uniqueness_of :ingest_id, scope: :node_id
end
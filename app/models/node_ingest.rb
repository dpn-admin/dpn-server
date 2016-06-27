# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class NodeIngest < ActiveRecord::Base
  self.table_name = "nodes_ingests"
  
  before_destroy :cannot_be_destroyed

  belongs_to :ingest, inverse_of: :node_ingests, touch: true
  belongs_to :node,   inverse_of: :node_ingests, touch: false

  validates :ingest_id, read_only: true, on: :update
  validates :node_id, read_only: true, on: :update
  validates_uniqueness_of :ingest_id, scope: :node_id
  
  private
  
  def cannot_be_destroyed
    errors.add(:base, "Destroying this record is not allowed.")
    raise ActiveRecord::RecordInvalid, self
  end
end
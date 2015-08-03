# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ChangeBagsTable < ActiveRecord::Migration
  def change
    rename_column :bags, :original_node_id, :ingest_node_id
  end
end

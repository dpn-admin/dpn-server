# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class AddIndexToFixityChecks < ActiveRecord::Migration
  def change
    add_index :fixity_checks, [:bag_id, :fixity_alg_id], unique: true
  end
end

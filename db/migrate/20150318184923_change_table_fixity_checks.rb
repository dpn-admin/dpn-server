# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ChangeTableFixityChecks < ActiveRecord::Migration
  def change
    change_table :fixity_checks do |t|
      t.remove :node_id
    end
  end
end

# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class AddFieldToNode < ActiveRecord::Migration
  def change
    change_table :nodes do |t|
      t.string :api_root
      t.index :api_root
    end
  end
end

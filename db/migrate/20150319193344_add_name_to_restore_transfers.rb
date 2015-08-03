# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class AddNameToRestoreTransfers < ActiveRecord::Migration
  def change
    change_table :restore_transfers do |t|
      t.string :name
      t.index :name
    end
  end
end

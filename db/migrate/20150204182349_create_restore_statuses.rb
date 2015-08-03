# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class CreateRestoreStatuses < ActiveRecord::Migration
  def change
    create_table :restore_statuses do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :restore_statuses, :name, unique: true
  end
end

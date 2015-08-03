# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class CreateStorageRegions < ActiveRecord::Migration
  def change
    create_table :storage_regions do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :storage_regions, :name, unique: true
  end
end

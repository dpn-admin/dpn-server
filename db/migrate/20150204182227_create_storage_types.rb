# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class CreateStorageTypes < ActiveRecord::Migration
  def change
    create_table :storage_types do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :storage_types, :name, unique: true
  end
end

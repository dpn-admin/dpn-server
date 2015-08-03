# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class CreateVersionFamily < ActiveRecord::Migration
  def change
    create_table :version_families do |t|
      t.string :uuid, null: false
    end
    add_index :version_families, [:uuid], unique: true

  end
end

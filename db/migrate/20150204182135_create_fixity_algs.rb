# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class CreateFixityAlgs < ActiveRecord::Migration
  def change
    create_table :fixity_algs do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :fixity_algs, :name, unique: true
  end
end

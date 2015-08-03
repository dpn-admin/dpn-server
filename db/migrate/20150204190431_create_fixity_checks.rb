# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class CreateFixityChecks < ActiveRecord::Migration
  def change
    create_table :fixity_checks do |t|
      t.references :node, null: false
      t.references :bag, null: false
      t.references :fixity_alg, null: false
      t.text :value, null: false
      t.timestamp null: false
    end
  end
end

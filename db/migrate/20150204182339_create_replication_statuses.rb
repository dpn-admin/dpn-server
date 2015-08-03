# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class CreateReplicationStatuses < ActiveRecord::Migration
  def change
    create_table :replication_statuses do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :replication_statuses, :name, unique: true
  end
end

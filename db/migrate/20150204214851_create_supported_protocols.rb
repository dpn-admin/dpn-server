# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class CreateSupportedProtocols < ActiveRecord::Migration
  def change
    create_table :supported_protocols do |t|
      t.references :node, null: false
      t.references :protocol, null: false
    end
    add_index :supported_protocols, [:node_id, :protocol_id], unique: true
  end
end

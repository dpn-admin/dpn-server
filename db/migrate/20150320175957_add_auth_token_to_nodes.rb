# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class AddAuthTokenToNodes < ActiveRecord::Migration
  def change
    change_table :nodes do |t|
      t.string :private_auth_token
      t.index :private_auth_token, unique: true
    end
  end
end

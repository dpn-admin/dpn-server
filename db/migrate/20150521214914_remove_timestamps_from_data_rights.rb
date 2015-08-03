# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class RemoveTimestampsFromDataRights < ActiveRecord::Migration
  def change
    remove_column :data_rights, :created_at, :string
    remove_column :data_rights, :updated_at, :string
  end
end

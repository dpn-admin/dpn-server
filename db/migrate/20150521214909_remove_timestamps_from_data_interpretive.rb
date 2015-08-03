# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class RemoveTimestampsFromDataInterpretive < ActiveRecord::Migration
  def change
    remove_column :data_interpretive, :created_at, :string
    remove_column :data_interpretive, :updated_at, :string
  end
end

# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ChangeSize < ActiveRecord::Migration
  def change
    change_column :bags, :size, :integer, :limit => 8
  end
end

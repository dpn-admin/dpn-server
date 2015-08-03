# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ChangeFieldOnBagManagerRequest < ActiveRecord::Migration
  def change
    rename_column :bag_manager_requests, :bag_valid, :validity
  end
end

# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class AddCancelledFieldToBagManagerRequest < ActiveRecord::Migration
  def change
    add_column :bag_manager_requests, :cancelled, :boolean, default: false
  end
end

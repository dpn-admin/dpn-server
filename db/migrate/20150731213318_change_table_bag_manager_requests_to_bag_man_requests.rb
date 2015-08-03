# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ChangeTableBagManagerRequestsToBagManRequests < ActiveRecord::Migration
  def change
    rename_table :bag_manager_requests, :bag_man_requests
  end
end

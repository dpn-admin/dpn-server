# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ChangeTableBags < ActiveRecord::Migration
  def change
    rename_column :bags, :first_version_bag_id, :version_family_id
  end
end

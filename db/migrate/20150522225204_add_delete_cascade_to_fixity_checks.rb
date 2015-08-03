# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class AddDeleteCascadeToFixityChecks < ActiveRecord::Migration
  def change
    remove_foreign_key :fixity_checks, :bags
    add_foreign_key :fixity_checks, :bags, on_update: :cascade, on_delete: :cascade
  end
end

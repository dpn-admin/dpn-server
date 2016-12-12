# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class AddBagsToFixityChecks < ActiveRecord::Migration
  def change
    add_foreign_key :fixity_checks, :bags,
      name: 'fixity_checks_bags_id_fk',
      on_delete: :cascade,
      on_update: :cascade
  end
end

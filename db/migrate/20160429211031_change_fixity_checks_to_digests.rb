# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class ChangeFixityChecksToDigests < ActiveRecord::Migration

  def up
    # Foreign keys are not renamed when you rename the table.
    # We recreate this fk after renaming the table.
    remove_foreign_key :fixity_checks, :bags
    rename_table :fixity_checks, :message_digests
  end

  def down
    rename_table :message_digests, :fixity_checks
    add_foreign_key :fixity_checks, :bags,
      column: :bag_id,
      on_delete: :cascade,
      on_update: :cascade
  end
end

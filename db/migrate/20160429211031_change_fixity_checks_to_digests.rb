# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class ChangeFixityChecksToDigests < ActiveRecord::Migration

  class Bag < ActiveRecord::Base
  end

  class FixityCheck < ActiveRecord::Base
    belongs_to :bag
  end

  def up
    add_column :fixity_checks, :node_id, :integer
    add_foreign_key :fixity_checks, :nodes,
      column: :node_id,
      on_delete: :nullify,
      on_update: :cascade
    add_column :fixity_checks, :created_at, :datetime

    FixityCheck.all.each do |fc|
      fc.update!(node_id: fc.bag.admin_node_id)
    end

    change_column :fixity_checks, :node_id, :integer, null: false
    change_column :fixity_checks, :created_at, :datetime, null: false

    rename_table :fixity_checks, :message_digests
  end

  def down
    rename_table :message_digests, :fixity_checks
    remove_column :fixity_checks, :node_id
    remove_column :fixity_checks, :created_at
  end
end

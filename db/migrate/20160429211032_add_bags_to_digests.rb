# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class AddBagsToDigests < ActiveRecord::Migration
  def change
    # bag_id exists already
    add_foreign_key :message_digests, :bags,
      name: 'message_digests_bags_id_fk',
      column: 'bag_id',
      on_delete: :cascade,
      on_update: :cascade
  end
end

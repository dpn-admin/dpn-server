class EnableFkMessageDigestsNodes < ActiveRecord::Migration

  class Bag < ActiveRecord::Base
  end

  class MessageDigest < ActiveRecord::Base
    belongs_to :bag
  end

  def up
    remove_foreign_key :message_digests, :nodes

    add_foreign_key :message_digests, :nodes,
      name: 'message_digests_nodes_id_fk',
      column: 'node_id',
      on_delete: :restrict,
      on_update: :cascade
  end

  def down
    remove_foreign_key :message_digests, :nodes
  end
end

class DisableFkMessageDigestsNodes < ActiveRecord::Migration

  class Bag < ActiveRecord::Base
  end

  class MessageDigest < ActiveRecord::Base
    belongs_to :bag
  end

  def up
    remove_foreign_key :message_digests, :nodes
    remove_column :message_digests, :node_id
  end

  def down
    add_column :message_digests, :node_id, :integer

    MessageDigest.all.each do |md|
      md.update!(node_id: md.bag.admin_node_id)
    end

    add_foreign_key :message_digests, :nodes,
      name: 'message_digests_nodes_id_fk',
      column: 'node_id',
      on_delete: :restrict,
      on_update: :cascade
  end
end

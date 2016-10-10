class NodeNotNullInMessageDigest < ActiveRecord::Migration

  def change
    remove_foreign_key :message_digests, column: :node_id
    add_foreign_key :message_digests, :nodes,
      column: :node_id,
      on_delete: :restrict,
      on_update: :cascade

    MessageDigest.where(node_id: nil).all.each do |md|
      md.update!(node_id: md.bag.admin_node_id)
    end
    change_column :message_digests, :node_id, :integer, null: false
  end

end

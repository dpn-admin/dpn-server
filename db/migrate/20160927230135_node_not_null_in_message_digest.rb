class NodeNotNullInMessageDigest < ActiveRecord::Migration
  def up
    MessageDigest.where(node_id: nil).all.each do |md|
      md.update!(node_id: md.bag.admin_node_id)
    end
    change_column :message_digests, :node_id, :integer, null: false
  end

  def down
    change_column :message_digests, :node_id, :integer, null: true
  end
end

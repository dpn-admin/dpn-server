class NodeNotNullInMessageDigest < ActiveRecord::Migration
  def change
    MessageDigest.where(node_id: nil).all.each do |md|
      md.update!(node_id: md.bag.admin_node_id)
    end
    change_column_null :message_digests, :node_id, false
  end
end

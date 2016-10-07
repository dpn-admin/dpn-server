class NodeNotNullInMessageDigest < ActiveRecord::Migration
  def up
    add_column :message_digests, :node_id, :integer, null: false

    MessageDigest.all.each do |md|
      md.update!(node_id: md.bag.admin_node_id)
    end
  end

  def down
    remove_column :message_digests, :node_id
  end
end

class NodeNotNullInMessageDigest < ActiveRecord::Migration
  def change
    change_column_null :message_digests, :node_id, false
  end
end

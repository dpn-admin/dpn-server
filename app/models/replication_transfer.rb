class ReplicationTransfer < ActiveRecord::Base
  belongs_to :from_node, :class_name => "Node", :foreign_key => "from_node_id"
  belongs_to :to_node, :class_name => "Node", :foreign_key => "to_node_id"
  belongs_to :bag
  belongs_to :fixity_alg
  belongs_to :replication_status
  belongs_to :protocol
end
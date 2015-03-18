class RestoreAgreement < ActiveRecord::Base
  belongs_to :from_node, :foreign_key => "from_node_id", :class_name => "Node"
  belongs_to :to_node, :foreign_key => "to_node_id", :class_name => "Node"
end
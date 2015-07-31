class RestoreTransfer < ActiveRecord::Base
  belongs_to :from_node, :class_name => "Node", :foreign_key => "from_node_id"
  belongs_to :to_node, :class_name => "Node", :foreign_key => "to_node_id"
  belongs_to :bag
  belongs_to :restore_status
  belongs_to :protocol

  include Lowercased
  make_lowercased :restore_id

  validates :restore_id, presence: true, uniqueness: true
end
class ReplicationTransfer < ActiveRecord::Base
  belongs_to :from_node, :class_name => "Node", :foreign_key => "from_node_id"
  belongs_to :to_node, :class_name => "Node", :foreign_key => "to_node_id"
  belongs_to :bag
  belongs_to :fixity_alg
  belongs_to :replication_status
  belongs_to :protocol

  include Lowercased
  make_lowercased :replication_id

  validates :replication_id, presence: true, uniqueness: true
  validates :link, presence: true
  validates :fixity_value, presence: true, if: "replication_status.name == \"received\""
  validates :fixity_value, presence: true, if: "replication_status.name == \"confirmed\""
  validates :fixity_value, presence: true, if: "replication_status.name == \"stored\""
  validates :bag_valid, :inclusion => {:in => [true, false]}, if: "replication_status.name == \"received\""
  validates :bag_valid, :inclusion => {:in => [true, false]}, if: "replication_status.name == \"confirmed\""
  validates :bag_valid, :inclusion => {:in => [true, false]}, if: "replication_status.name == \"stored\""
  validates :fixity_accept, :inclusion => {:in => [true, false]}, if: "replication_status.name == \"confirmed\""
  validates :fixity_accept, :inclusion => {:in => [true, false]}, if: "replication_status.name == \"stored\""
end
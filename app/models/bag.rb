class Bag < ActiveRecord::Base
  belongs_to :ingest_node, :foreign_key => "ingest_node_id", :class_name => "Node"
  belongs_to :admin_node, :foreign_key => "admin_node_id", :class_name => "Node"
  has_many :fixity_checks

  belongs_to :version_family, :inverse_of => :bags

  has_many :replication_transfers
  has_many :restore_transfers

  has_and_belongs_to_many :replicating_nodes, :join_table => "replicating_nodes", :class_name => "Node", :uniq => true

  include UUIDFormat
  make_uuid :uuid

end
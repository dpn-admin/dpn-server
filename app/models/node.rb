class Node < ActiveRecord::Base
  has_many :original_bags, :class_name => "Bag", :foreign_key => "original_node_id"
  has_many :admin_bags, :class_name => "Bag", :foreign_key => "admin_node_id"
  has_many :fixity_checks

  belongs_to :storage_region
  belongs_to :storage_type

  has_and_belongs_to_many :fixity_algs, :join_table => "supported_fixity_algs", :uniq => true
  has_and_belongs_to_many :protocols, :join_table => "supported_protocols", :uniq => true

  has_many :replicator_agreements, :foreign_key => "from_node_id", :class_name => "ReplicationAgreement"
  has_many :to_nodes, :through => :replicator_agreements

  has_many :replicatee_agreements, :foreign_key => "to_node_id", :class_name => "ReplicationAgreement"
  has_many :from_nodes, :through => :replicatee_agreements

  has_many :replication_transfers_from, :class_name => "ReplicationTransfer", :foreign_key => "from_node_id"
  has_many :replication_transfers_to, :class_name => "ReplicationTransfer", :foreign_key => "to_node_id"

end
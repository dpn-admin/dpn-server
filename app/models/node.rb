class Node < ActiveRecord::Base
  has_many :ingest_bags, :class_name => "Bag", :foreign_key => "ingest_node_id"
  has_many :admin_bags, :class_name => "Bag", :foreign_key => "admin_node_id"

  belongs_to :storage_region
  belongs_to :storage_type

  has_and_belongs_to_many :fixity_algs, :join_table => "supported_fixity_algs", :uniq => true
  has_and_belongs_to_many :protocols, :join_table => "supported_protocols", :uniq => true

  has_many :replicator_agreements, :foreign_key => "from_node_id", :class_name => "ReplicationAgreement"
  has_many :replicate_to_nodes, :through => :replicator_agreements

  has_many :replicatee_agreements, :foreign_key => "to_node_id", :class_name => "ReplicationAgreement"
  has_many :replicate_from_nodes, :through => :replicatee_agreements

  has_many :restorer_agreements, :foreign_key => "from_node_id", :class_name => "RestoreAgreement"
  has_many :restore_to_nodes, :through => :restorer_agreements

  has_many :restoree_agreements, :foreign_key => "to_node_id", :class_name => "RestoreAgreement"
  has_many :restore_from_nodes, :through => :restoree_agreements

  has_many :replication_transfers_from, :class_name => "ReplicationTransfer", :foreign_key => "from_node_id"
  has_many :replication_transfers_to, :class_name => "ReplicationTransfer", :foreign_key => "to_node_id"

  has_many :restore_transfers_from, :class_name => "RestoreTransfer", :foreign_key => "from_node_id"
  has_many :restore_transfers_to, :class_name => "RestoreTransfer", :foreign_key => "to_node_id"

  has_and_belongs_to_many :replicated_bags, :join_table => "replicating_nodes", :uniq => true

  include Lowercased
  make_lowercased :namespace

end
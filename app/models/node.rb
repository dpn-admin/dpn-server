require 'bcrypt'

class Node < ActiveRecord::Base
  has_many :ingest_bags, class_name: "Bag", foreign_key: "ingest_node_id"
  has_many :admin_bags, class_name: "Bag", foreign_key: "admin_node_id"

  belongs_to :storage_region
  belongs_to :storage_type

  has_and_belongs_to_many :fixity_algs, join_table: "supported_fixity_algs", uniq: true
  has_and_belongs_to_many :protocols, join_table: "supported_protocols", uniq: true

  has_many :replicator_agreements, foreign_key: "from_node_id", class_name: "ReplicationAgreement", inverse_of: :from_node
  has_many :replicate_to_nodes, through: :replicator_agreements, source: :to_node

  has_many :replicatee_agreements, foreign_key:  "to_node_id", class_name: "ReplicationAgreement", inverse_of: :to_node
  has_many :replicate_from_nodes, through: :replicatee_agreements, source: :from_node

  has_many :restorer_agreements, foreign_key: "from_node_id", class_name: "RestoreAgreement", inverse_of: :from_node
  has_many :restore_to_nodes, through: :restorer_agreements, source: :to_node

  has_many :restoree_agreements, foreign_key: "to_node_id", class_name: "RestoreAgreement", inverse_of: :to_node
  has_many :restore_from_nodes, through: :restoree_agreements, source: :from_node

  has_many :replication_transfers_from, class_name: "ReplicationTransfer", foreign_key: "from_node_id"
  has_many :replication_transfers_to, class_name: "ReplicationTransfer", foreign_key: "to_node_id"

  has_many :restore_transfers_from, class_name: "RestoreTransfer", foreign_key: "from_node_id"
  has_many :restore_transfers_to, class_name: "RestoreTransfer", foreign_key: "to_node_id"

  has_and_belongs_to_many :replicated_bags, join_table: "replicating_nodes", uniq: true

  include Lowercased
  make_lowercased :namespace

  validates :namespace, presence: true, uniqueness: true
  validates :name, presence: true, length: { minimum: 1 }
  validates :private_auth_token, presence: true, uniqueness: true
  validates :api_root, presence: true, uniqueness: true

  def private_auth_token=(value)
    write_attribute(:private_auth_token, generate_hash(value))
  end

  def find_by_private_auth_token(value)
    super(generate_hash(value))
  end

  protected
  def generate_hash(raw_value)
    return raw_value
    #return BCrypt::Password.create("#{Rails.application.config.salt}#{raw_value}")
  end

end
require 'bcrypt'

class Node < ActiveRecord::Base

  ### Modifications and Concerns
  include Lowercased
  make_lowercased :namespace

  def self.local_node!
    self.find_by_namespace!(Rails.configuration.local_namespace)
  end

  # Auth Token
  def private_auth_token=(value)
    write_attribute(:private_auth_token, Node.generate_hash(value))
  end

  def self.find_by_private_auth_token(value)
    Node.find_by(private_auth_token: Node.generate_hash(value))
  end


  # Auth Credential
  def auth_credential=(value)
    if value
      value = encrypt(value)
    end
    write_attribute(:auth_credential, value)
  end

  def auth_credential
    value = read_attribute(:auth_credential)
    if value
      decrypt(read_attribute(:auth_credential))
    else
      value
    end
  end


  ### Associations
  has_many :ingest_bags, class_name: "Bag", foreign_key: "ingest_node_id", autosave: true,
           inverse_of: :ingest_node

  has_many :admin_bags, class_name: "Bag", foreign_key: "admin_node_id", autosave: true,
           inverse_of: :admin_node

  belongs_to :storage_region, autosave: true, inverse_of: :nodes
  belongs_to :storage_type, autosave: true, inverse_of: :nodes

  has_and_belongs_to_many :fixity_algs, join_table: "supported_fixity_algs", uniq: true,
                          autosave: true, inverse_of: :nodes

  has_and_belongs_to_many :protocols, join_table: "supported_protocols", uniq: true,
                          autosave: true, inverse_of: :nodes

  has_many :replicator_agreements, foreign_key: "from_node_id", class_name: "ReplicationAgreement",
           autosave: true, inverse_of: :from_node
  has_many :replicate_to_nodes, through: :replicator_agreements, source: :to_node

  has_many :replicatee_agreements, foreign_key:  "to_node_id", class_name: "ReplicationAgreement",
           autosave: true, inverse_of: :to_node
  has_many :replicate_from_nodes, through: :replicatee_agreements, source: :from_node

  has_many :restorer_agreements, foreign_key: "from_node_id", class_name: "RestoreAgreement",
           autosave: true, inverse_of: :from_node
  has_many :restore_to_nodes, through: :restorer_agreements, source: :to_node

  has_many :restoree_agreements, foreign_key: "to_node_id", class_name: "RestoreAgreement",
           autosave: true, inverse_of: :to_node
  has_many :restore_from_nodes, through: :restoree_agreements, source: :from_node

  has_many :replication_transfers_from, class_name: "ReplicationTransfer", foreign_key: "from_node_id",
           inverse_of: :from_node
  has_many :replication_transfers_to, class_name: "ReplicationTransfer", foreign_key: "to_node_id",
           inverse_of: :to_node

  has_many :restore_transfers_from, class_name: "RestoreTransfer", foreign_key: "from_node_id",
           inverse_of: :from_node
  has_many :restore_transfers_to, class_name: "RestoreTransfer", foreign_key: "to_node_id",
           inverse_of: :to_node

  has_and_belongs_to_many :replicated_bags, join_table: "replicating_nodes", uniq: true,
                          inverse_of: :replicating_nodes, class_name: "Bag"

  ### ActiveModel::Dirty Validations
  validates_with ChangeValidator # Only perform a save if the record actually changed.
  validates :namespace, read_only: true, on: :update


  ### Static Validations
  validates :namespace, presence: true, uniqueness: true
  validates :name, presence: true, length: { minimum: 1 }
  validates :private_auth_token, presence: true, uniqueness: true
  validates :api_root, presence: true, uniqueness: true




  protected
  def self.generate_hash(raw_value)
    if Rails.env.production?
      return Digest::SHA256.base64digest("#{Rails.application.config.salt}#{raw_value}")
    else
      return raw_value
    end
  end

  def encrypt(value)
    Rails.configuration.cipher.encrypt(value)
  end

  def decrypt(value)
    Rails.configuration.cipher.decrypt(value)
  end

end
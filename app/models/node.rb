# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'bcrypt'

class Node < ActiveRecord::Base

  ### Modifications and Concerns
  include ManagedUpdate
  include Lowercased
  make_lowercased :namespace

  def self.find_fields
    Set.new [:namespace]
  end

  def self.local_node!
    self.find_by_namespace!(Rails.configuration.local_namespace)
  end

  def local_node?
    namespace == Rails.configuration.local_namespace
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


  def update_with_associations(new_attributes)
    return set_attributes_with_associations(new_attributes) do |node|
      node.save
    end
  end


  def update_with_associations!(new_attributes)
    set_attributes_with_associations(new_attributes) do |node|
      node.save!
    end
  end


  ### Associations
  has_many :ingest_bags, class_name: "Bag", foreign_key: "ingest_node_id", autosave: true,
           inverse_of: :ingest_node

  has_many :admin_bags, class_name: "Bag", foreign_key: "admin_node_id", autosave: true,
           inverse_of: :admin_node
  
  has_many :fixity_checks, inverse_of: :node

  has_many :node_ingests, inverse_of: :node
  has_many :ingests, through: :node_ingests, source: :ingest

  belongs_to :storage_region, autosave: true, inverse_of: :nodes
  belongs_to :storage_type, autosave: true, inverse_of: :nodes

  has_many :supported_fixity_algs, inverse_of: :node
  has_many :fixity_algs, through: :supported_fixity_algs

  has_many :supported_protocols, inverse_of: :node
  has_many :protocols, through: :supported_protocols

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

  has_many :bag_nodes, inverse_of: :node
  has_many :replicated_bags, through: :bag_nodes, source: :bag

  ### ActiveModel::Dirty Validations
  validates :namespace, read_only: true, on: :update


  ### Static Validations
  validates :namespace, presence: true
  validates :name, presence: true, length: { minimum: 1 }
  validates :private_auth_token, presence: true, uniqueness: true
  validates :api_root, presence: true, uniqueness: true

  ### Scopes
  scope :updated_before, ->(time) { where("updated_at < ?", time) unless time.blank? }
  scope :updated_after, ->(time) { where("updated_at > ?", time) unless time.blank? }


  protected
  def self.generate_hash(raw_value)
    if Rails.env.production?
      return Digest::SHA256.hexdigest("#{Rails.application.config.salt}#{raw_value.strip}")
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

  def set_attributes_with_associations(new_attributes, &block)
    new_attributes = new_attributes.with_indifferent_access
    self.attributes = new_attributes.slice *(attribute_names - ["private_auth_token", "auth_credential"] )
    self.replicate_from_nodes = new_attributes[:replicate_from_nodes]
    self.replicate_to_nodes = new_attributes[:replicate_to_nodes]
    self.restore_from_nodes = new_attributes[:restore_from_nodes]
    self.restore_to_nodes = new_attributes[:restore_to_nodes]
    self.protocols = new_attributes[:protocols]
    self.fixity_algs = new_attributes[:fixity_algs]
    if new_attributes[:private_auth_token]
      self.private_auth_token = new_attributes[:private_auth_token]
    end
    if new_attributes[:auth_credential]
      self.auth_credential = new_attributes[:auth_credential]
    end
    yield self
  end

end
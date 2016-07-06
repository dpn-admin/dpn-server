# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class Bag < ActiveRecord::Base

  ### Modifications and Concerns
  include ManagedUpdate
  include Lowercased
  make_lowercased :uuid

  def to_param
    uuid
  end
  
  
  ### Associations
  belongs_to :ingest_node, :foreign_key => "ingest_node_id", :class_name => "Node",
             autosave: true, inverse_of: :ingest_bags
  belongs_to :admin_node, :foreign_key => "admin_node_id", :class_name => "Node",
             autosave: true, inverse_of: :admin_bags
  belongs_to :member, :foreign_key => "member_id", :class_name => "Member",
             autosave: true, inverse_of: :bags

  has_many :message_digests, autosave: true, dependent: :destroy, inverse_of: :bag
  validates_associated :message_digests
  
  has_many :fixity_checks, inverse_of: :bag
  has_many :ingests, inverse_of: :bag

  belongs_to :version_family, :inverse_of => :bags, autosave: true
  validates_associated :version_family

  has_many :replication_transfers, autosave: true, inverse_of: :bag
  has_many :restore_transfers, autosave: true, inverse_of: :bag

  has_many :bag_nodes, inverse_of: :bag
  has_many :replicating_nodes, through: :bag_nodes, source: :node
  
  ### ActiveModel::Dirty Validations
  validates :uuid, read_only: true, on: :update
  validates :ingest_node_id, read_only: true, on: :update
  validates :size, read_only: true, on: :update
  validates :version, read_only: true, on: :update
  validates :version_family_id, read_only: true, on: :update

  ### Static Validations
  validates :uuid, presence: true, uniqueness: true,
            format: { with: /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i,
            message: "must be a valid v4 uuid." }

  validates :ingest_node, presence: true
  validates :admin_node, presence: true
  validates :member, presence: true
  validates :local_id, presence: true, uniqueness: true
  validates :size, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :version_family, presence: true
  validates :version, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates_uniqueness_of :version, :scope => :version_family
  validate :self_legal_if_first_version?, on: [:create, :update], unless: "version_family_id.nil?"


  ### Scopes
  scope :updated_before, ->(time) { where("updated_at < ?", time) unless time.blank? }
  scope :updated_after, ->(time) { where("updated_at > ?", time) unless time.blank? }
  scope :with_admin_node_id, ->(id) { where(admin_node_id: id) unless id.blank? }
  scope :with_member_id, ->(id) { where(member_id: id) unless id.blank? }
  scope :with_bag_type, ->(bag_type) { where(type: bag_type) unless bag_type.blank? }


  private
  def self.legal_if_first_version?(version, uuid, version_family_uuid)
    if version == 1 || uuid == version_family_uuid
      return uuid == version_family_uuid && version == 1
    else
      return true
    end
  end

  def self_legal_if_first_version?
    unless Bag.legal_if_first_version?(version, uuid, version_family.uuid)
      errors.add(:version, "version == 1 IFF uuid==version_family.uuid\n" +
        "\tgot version=#{version}, uuid=#{uuid}, version_family.uuid=#{version_family.uuid}")
    end
  end
  
 
  

end

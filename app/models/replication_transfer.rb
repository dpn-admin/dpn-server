# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ReplicationTransfer < ActiveRecord::Base

  ### Modifications and Concerns
  include ManagedUpdate
  include Lowercased
  make_lowercased :replication_id

  def to_param
    replication_id
  end

  def self.find_fields
    Set.new [:replication_id]
  end



  def cancel!(reason, detail)
    unless cancelled
      transaction do
        update!(cancelled: true, cancel_reason: reason, cancel_reason_detail: detail)
        bag_man_request&.cancel!(reason)
      end
    end
    return true
  end


  ### Associations
  belongs_to :from_node, class_name: "Node", foreign_key: "from_node_id",
    inverse_of: :replication_transfers_from
  belongs_to :to_node, class_name: "Node", foreign_key: "to_node_id",
    inverse_of: :replication_transfers_to
  belongs_to :bag
  belongs_to :fixity_alg
  belongs_to :protocol
  has_one :bag_man_request, inverse_of: :replication_transfer


  ### Callbacks
  after_create :add_request_if_needed


  ### Static Validations
  validates :replication_id, presence: true
  validates :from_node, presence: true
  validates :to_node, presence: true
  validates :bag, presence: true
  validates :protocol, presence: true
  validates :fixity_alg, presence: true
  validates :link, presence: true
  validates :store_requested, inclusion: {in: [false, true]}
  validates :stored, inclusion: {in: [false, true]}
  validates :cancelled, inclusion: {in: [false, true]}
  validates :replication_id,
    format: { with: /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i,
      message: "must be a valid v4 uuid." }


  ### ActiveModel::Dirty Validations
  validate :no_changes_once_cancelled,  on: :update
  validate :no_changes_once_stored,     on: :update
  validates :replication_id,  read_only: true, on: :update
  validates :from_node_id,    read_only: true, on: :update
  validates :to_node_id,      read_only: true, on: :update
  validates :bag_id,          read_only: true, on: :update
  validates :fixity_alg_id,   read_only: true, on: :update
  validates :fixity_nonce,    read_only: true, on: :update
  validates :protocol_id,     read_only: true, on: :update
  validates :link,            read_only: true, on: :update
  validates :created_at,      read_only: true, on: :update
  validates :fixity_value,    read_only: true, on: :update, unless: proc {|r| r.fixity_value_changed?(from: nil)}
  validates :store_requested, read_only: true, on: :update, unless: proc {|r| r.store_requested_changed?(from: false, to: true)}
  validates :stored,          read_only: true, on: :update, unless: proc {|r| r.stored_changed?(from: false, to: true)}
  validates :cancelled,       read_only: true, on: :update, unless: proc {|r| r.cancelled_changed?(from: false, to: true)}
  validates :cancel_reason,   read_only: true, on: :update, unless: proc {|r| r.cancelled_changed?(from: false, to: true)}
  validates :cancel_reason_detail, read_only: true, on: :update, unless: proc {|r| r.cancelled_changed?(from: false, to: true)}



  ### Scopes
  scope :updated_after, ->(time) { where("updated_at > ?", time) unless time.blank? }
  scope :updated_before, ->(time) { where("updated_at < ?", time) unless time.blank? }
  scope :with_bag, ->(bag) { where(bag: bag) unless bag.new_record? }
  scope :with_from_node, ->(node) { where(from_node: node) unless node.new_record? }
  scope :with_to_node, ->(node) { where(to_node: node) unless node.new_record? }
  scope :with_store_requested, ->(v){ where(store_requested: v) if [true,false].include?(v) }
  scope :with_stored, ->(v){ where(stored: v) if [true,false].include?(v) }
  scope :with_cancelled, ->(v){ where(cancelled: v) if [true,false].include?(v) }
  scope :with_cancel_reason, ->(reason){ where(cancel_reason: reason) unless reason.blank? }



  private

  # Cancelled records are read-only.
  def no_changes_once_cancelled
    if changed? && cancelled_was == true
      errors.add(:base, "cannot change a cancelled record.")
    end
  end


  # Stored records are read-only.
  def no_changes_once_stored
    if changed? && stored_was == true
      errors.add(:base, "cannot change a stored record.")
    end
  end


  # If we are the to_node, create a bag_man_request and
  # associate it with this record.
  def add_request_if_needed
    if to_node&.local_node?
      self.bag_man_request = BagManRequest.create!( source_location: link, cancelled: false)
      self.bag_man_request.begin!
    end
  end


end

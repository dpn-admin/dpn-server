# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class RestoreTransfer < ActiveRecord::Base

  ### Modifications and Concerns
  include ManagedUpdate
  include Lowercased
  make_lowercased :restore_id

  def to_param
    restore_id
  end

  def self.find_fields
    Set.new [:restore_id]
  end

  def cancel!(reason, detail)
    unless cancelled
      update!(cancelled: true, cancel_reason: reason, cancel_reason_detail: detail)
    end
  end


  ### Associations
  belongs_to :from_node, class_name: "Node", foreign_key: "from_node_id",
    inverse_of: :restore_transfers_from
  belongs_to :to_node, class_name: "Node", foreign_key: "to_node_id",
    inverse_of: :restore_transfers_to
  belongs_to :bag
  belongs_to :protocol


  ### Static Validations
  validates :restore_id, uniqueness: true, presence: true
  validates :from_node, presence: true
  validates :to_node, presence: true
  validates :bag, presence: true
  validates :protocol, presence: true
  validates :accepted, inclusion: {in: [false, true]}
  validates :finished, inclusion: {in: [false, true]}
  validates :cancelled, inclusion: {in: [false, true]}
  validates :restore_id,
    format: { with: /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i,
      message: "must be a valid v4 uuid." }


  ### ActiveModel::Dirty Validations
  validate :no_changes_once_cancelled,  on: :update
  validate :no_changes_once_finished,   on: :update
  validates :restore_id,      read_only: true, on: :update
  validates :from_node_id,    read_only: true, on: :update
  validates :to_node_id,      read_only: true, on: :update
  validates :bag_id,          read_only: true, on: :update
  validates :protocol_id,     read_only: true, on: :update
  validates :created_at,      read_only: true, on: :update
  validates :link,            read_only: true, on: :update, unless: proc {|r| r.link_changed?(from: nil)}
  validates :accepted,        read_only: true, on: :update, unless: proc {|r| r.accepted_changed?(from: false, to: true)}
  validates :finished,        read_only: true, on: :update, unless: proc {|r| r.finished_changed?(from: false, to: true)}
  validates :cancelled,       read_only: true, on: :update, unless: proc {|r| r.cancelled_changed?(from: false, to: true)}
  validates :cancel_reason,   read_only: true, on: :update, unless: proc {|r| r.cancelled_changed?(from: false, to: true)}
  validates :cancel_reason_detail, read_only: true, on: :update, unless: proc {|r| r.cancelled_changed?(from: false, to: true)}


  ### Scopes
  scope :updated_after, ->(time) { where("updated_at > ?", time) unless time.blank? }
  scope :updated_before, ->(time) { where("updated_at < ?", time) unless time.blank? }
  scope :with_bag_id, ->(id) { where(bag_id: id) unless id.blank? }
  scope :with_from_node_id, ->(id) { where(from_node_id: id) unless id.blank? }
  scope :with_to_node_id, ->(id) { where(to_node_id: id) unless id.blank? }
  scope :with_accepted, ->(v){ where(accepted: v) unless v.blank? }
  scope :with_finished, ->(v){ where(finished: v) unless v.blank? }
  scope :with_cancelled, ->(v){ where(cancelled: v) unless v.blank? }
  scope :with_cancel_reason, ->(reason){ where(cancel_reason: reason) unless reason.blank? }

  private

  # Cancelled records are read-only.
  def no_changes_once_cancelled
    if changed? && cancelled_was == true
      errors.add(:base, "cannot change a cancelled record.")
    end
  end


  # Finished records are read-only.
  def no_changes_once_finished
    if changed? && finished_was == true
      errors.add(:base, "cannot change a finished record.")
    end
  end

end
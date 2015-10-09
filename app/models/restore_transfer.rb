# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class RestoreTransfer < ActiveRecord::Base

  ### Modifications and Concerns
  include Lowercased
  make_lowercased :restore_id

  def to_param
    restore_id
  end

  enum status: {
    requested: 0,
    accepted: 1,
    rejected: 2,
    prepared: 3,
    finished: 4,
    cancelled: 5
  }

  attr_accessor :requester
  def requester
    @requester
  end
  def requester=(value)
    @requester=value
  end


  ### Associations
  belongs_to :from_node, :class_name => "Node", :foreign_key => "from_node_id"
  belongs_to :to_node, :class_name => "Node", :foreign_key => "to_node_id"
  belongs_to :bag
  belongs_to :protocol


  ### Callbacks
  before_validation do |record|
    if record.restore_id == nil && record.to_node && record.to_node.namespace == Rails.configuration.local_namespace
      record.restore_id = SecureRandom.uuid
    end
  end


  ### Static Validations
  validates :restore_id, uniqueness: true
  validates :restore_id, presence: true, on: :create, if: "to_node ? to_node.namespace != Rails.configuration.local_namespace : false"
  validates :restore_id, presence: false, on: :create, if: "to_node ? to_node.namespace == Rails.configuration.local_namespace : false"
  validates :from_node, presence: true
  validates :to_node, presence: true
  validates :bag, presence: true
  validates :protocol, presence: true
  validates :status, presence: true
  validates :restore_id, allow_nil: true,
    format: { with: /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i,
      message: "must be a valid v4 uuid." }


  ### ActiveModel::Dirty Validations
  validates_with ChangeValidator, on: :update
  validates :restore_id, read_only: true, on: :update
  validates :from_node_id, read_only: true, on: :update
  validates :to_node_id, read_only: true, on: :update
  validates :bag_id, read_only: true, on: :update
  validates :protocol_id, read_only: true, on: :update


  ### Scopes
  scope :updated_after, ->(time) { where("updated_at > ?", time) unless time.blank? }
  scope :with_bag_id, ->(id) { where(bag_id: id) unless id.blank? }
  scope :with_from_node_id, ->(id) { where(from_node_id: id) unless id.blank? }
  scope :with_to_node_id, ->(id) { where(to_node_id: id) unless id.blank? }
  scope :with_status, ->(status) {
    unless status.blank?
      where(status: RestoreTransfer.statuses[status])
    end
  }


end
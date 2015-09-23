# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ReplicationTransfer < ActiveRecord::Base

  ### Modifications and Concerns
  include UUIDFormat
  make_uuid :replication_id

  FIXITY_VALUE_STATES =  ["received", "confirmed", "stored"]
  BAG_VALID_STATES = ["received", "confirmed", "stored"]
  FIXITY_ACCEPT_STATES = ["confirmed", "stored"]

  ### Associations
  belongs_to :from_node, :class_name => "Node", :foreign_key => "from_node_id",
             inverse_of: :replication_transfers_from
  belongs_to :to_node, :class_name => "Node", :foreign_key => "to_node_id",
             inverse_of: :replication_transfers_to
  belongs_to :bag
  belongs_to :fixity_alg
  belongs_to :replication_status
  belongs_to :protocol
  belongs_to :bag_man_request, foreign_key: "bag_man_request_id", inverse_of: :replication_transfer

  ### Callbacks
  after_update do |record|
    if record.replication_status.changed? && bag_man_request != nil
      if [:stored, :rejected, :cancelled].include?(record.replication_status)
        record.bag_man_request.destroy
      end
    end
  end

  before_create do |record|
    if record.replication_id == nil && record.from_node.namespace == Rails.configuration.local_namespace
      record.replication_id = SecureRandom.uuid.delete('-').downcase
    end
  end

  ### Static Validations
  validates :replication_id, uniqueness: true
  validates :replication_id, read_only: true, on: :update
  validates :replication_id, presence: true, on: :create, if: "from_node.namespace != Rails.configuration.local_namespace"
  validates :replication_id, presence: false, on: :create, if: "from_node.namespace == Rails.configuration.local_namespace"
  validates :link, presence: true
  validates :replication_status, presence: true
  validates :fixity_value, presence: true, if: :check_fixity_value?
  validates :bag_valid, :inclusion => {:in => [true, false]}, if: :check_bag_valid?
  validates :fixity_accept, :inclusion => {:in => [true, false]}, if: :check_fixity_accept?

  ### ActiveModel::Dirty Validations
  validates_with ChangeValidator # Only perform a save if the record actually changed.

  private
  def check_fixity_value?
    !replication_status.nil? && FIXITY_VALUE_STATES.include?(replication_status.name)
  end

  def check_bag_valid?
    !replication_status.nil? && BAG_VALID_STATES.include?(replication_status.name)
  end

  def check_fixity_accept?
    !replication_status.nil? && FIXITY_ACCEPT_STATES.include?(replication_status.name)
  end

end

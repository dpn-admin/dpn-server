# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class ReplicationTransfer < ActiveRecord::Base

  ### Modifications and Concerns
  include Lowercased
  make_lowercased :replication_id

  def to_param
    replication_id
  end

  enum status: {
    requested: 0,
    rejected: 1,
    received: 2,
    confirmed: 3,
    stored: 4,
    cancelled: 5
  }

  FIXITY_CHECK_STATES = [:received, :requested]
  FIXITY_VALUE_STATES =  [:received, :confirmed, :stored]
  BAG_VALID_STATES = [:received, :confirmed, :stored]
  FIXITY_ACCEPT_STATES = [:confirmed, :stored]

  attr_accessor :requester
  def requester
    @requester
  end
  def requester=(value)
    @requester=value
  end


  ### Associations
  belongs_to :from_node, :class_name => "Node", :foreign_key => "from_node_id",
             inverse_of: :replication_transfers_from
  belongs_to :to_node, :class_name => "Node", :foreign_key => "to_node_id",
             inverse_of: :replication_transfers_to
  belongs_to :bag
  belongs_to :fixity_alg
  belongs_to :protocol
  has_one :bag_man_request, inverse_of: :replication_transfer


  ### Callbacks
  before_validation do |record|
    if record.replication_id == nil && record.from_node && record.from_node.namespace == Rails.configuration.local_namespace
      record.replication_id = SecureRandom.uuid.downcase
    end
  end

  before_update :set_fixity_accept, if: "they_received && fixity_value_changed?"

  before_update if: "bag_valid == false" do |record|
    record.status = :cancelled
    record.updated_at = Time.now
  end

  before_update if: "they_received && fixity_accept && bag_valid" do |record|
    record.status = :confirmed
    record.updated_at = Time.now
  end

  after_create do |record|
    if record.to_node.namespace == Rails.configuration.local_namespace && record.bag_man_request.nil?
      record.bag_man_request = BagManRequest.create!(source_location: link, cancelled: false)
    end
  end

  after_update do |record|
    if record.bag_man_request
      if record.status_changed?(from: "received", to: "confirmed") && record.fixity_accept == true
        record.bag_man_request.okay_to_preserve!
      end
    end
  end


  after_update do |record|
    if record.status_changed? && record.bag_man_request != nil
      if [:stored, :rejected, :cancelled].include?(record.status.to_sym)
        record.bag_man_request.cancelled = true
      end
    end
  end


  ### Static Validations
  validates :replication_id, uniqueness: true
  validates :replication_id, presence: true, on: :create, if: "from_node ? from_node.namespace != Rails.configuration.local_namespace : false"
  validates :replication_id, presence: false, on: :create, if: "from_node ? from_node.namespace == Rails.configuration.local_namespace : false"
  validates :from_node, presence: true
  validates :to_node, presence: true
  validates :bag, presence: true
  validates :protocol, presence: true
  validates :fixity_alg, presence: true
  validates :link, presence: true
  validates :status, presence: true
  # validates :fixity_value, presence: true, if: :check_fixity_value?
  # validates :bag_valid, :inclusion => {:in => [true, false]}, if: :check_bag_valid?
  # validates :fixity_accept, :inclusion => {:in => [true, false]}, if: :check_fixity_accept?
  validates :replication_id, allow_nil: true,
    format: { with: /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i,
      message: "must be a valid v4 uuid." }


  ### ActiveModel::Dirty Validations
  validates_with ChangeValidator # Only perform a save if the record actually changed.
  validates :replication_id, read_only: true, on: :update
  validates :from_node_id, read_only: true, on: :update
  validates :to_node_id, read_only: true, on: :update
  validates :bag_id, read_only: true, on: :update
  validates :fixity_alg_id, read_only: true, on: :update
  validates :fixity_nonce, read_only: true, on: :update
  validates :fixity_value, read_only: true, on: :update, unless: proc {|r| r.fixity_value_changed?(from: nil)}
  validates :fixity_accept, read_only: true, on: :update, unless: proc {|r| r.fixity_accept_changed?(from: nil)}
  validates :bag_valid, read_only: true, on: :update, unless: proc {|r| r.bag_valid_changed?(from: nil)}
  validates :protocol_id, read_only: true, on: :update
  validates :link, read_only: true, on: :update

  ## Special update validations
  validate :involved_or_local, on: :update, if: proc {|r| r.status_changed? && r.requester }
  validate :giant_case_statement, on: :update, if: proc {|r| r.status_changed? && r.requester}


  ### Scopes
  scope :updated_after, ->(time) { where("updated_at > ?", time) unless time.blank? }
  scope :with_bag_id, ->(id) { where(bag_id: id) unless id.blank? }
  scope :with_status, ->(status) { where(status: ReplicationTransfer.statuses[status]) unless status.blank? }
  scope :with_fixity_accept, ->(bool) { where(fixity_accept: bool) unless bool.blank? }
  scope :with_bag_valid, ->(bool) { where(bag_valid: bool) unless bool.blank? }
  scope :with_from_node_id, ->(id) { where(from_node_id: id) unless id.blank? }
  scope :with_to_node_id, ->(id) { where(to_node_id: id) unless id.blank? }



  private
  def set_fixity_accept
    fixity_check = bag.fixity_checks.find_by_fixity_alg_id(fixity_alg_id)
    if fixity_check
      self.fixity_accept = (fixity_check.value == fixity_value)
    else
      self.fixity_accept = false
    end
    unless self.fixity_accept
      self.status = :cancelled
    end
    self.updated_at = Time.now
  end


  def they_received
    received? && from_node.namespace == Rails.configuration.local_namespace
  end

  def check_fixity_value?
    FIXITY_VALUE_STATES.include?(status)
  end

  def check_bag_valid?
    BAG_VALID_STATES.include?(status)
  end

  def check_fixity_accept?
    FIXITY_ACCEPT_STATES.include?(status)
  end

  def involved_or_local
    if requester
      local_node = Node.find_by_namespace(Rails.configuration.local_namespace)
      allowed_nodes = [local_node]
      if from_node == local_node
        allowed_nodes << to_node
      end
      unless allowed_nodes.include? requester
        errors.add(:requester, "not local node or a node we are replicating to on this transfer.")
      end
    end
  end


  def giant_case_statement
    local_node = Node.find_by_namespace(Rails.configuration.local_namespace)
    case local_node
      when from_node
        role = :from_node
      when to_node
        role = :to_node
      else
        role = :none
    end

    case requester
      when local_node
        from = :us
      when to_node
        from = :to_node
      else
        from = nil
        errors.add(:requester, "is not part of this transfer.") and return
    end

    case [from, role, status_was.to_sym, status.to_sym]
      when [:us, :from_node, :requested, :cancelled]
        flag_changed_fields(:fixity_value, :fixity_accept, :bag_valid)
      when [:us, :from_node, :received, :confirmed]
        flag_changed_fields(:bag_valid, :fixity_value)
      when [:us, :from_node, :received, :cancelled]
        flag_changed_fields(:bag_valid, :fixity_value)
      when [:us, :from_node, :confirmed, :cancelled]
        flag_changed_fields(:bag_valid, :fixity_value, :fixity_accept)
      when [:us, :to_node, :requested, :rejected]
        flag_changed_fields(:bag_valid, :fixity_value, :fixity_accept)
      when [:us, :to_node, :requested, :received]
        flag_changed_fields(:fixity_accept)
      when [:us, :to_node, :requested, :confirmed]
      when [:us, :to_node, :requested, :cancelled]
        flag_changed_fields(:fixity_value, :fixity_accept, :bag_valid)
      when [:us, :to_node, :received, :confirmed]
        flag_changed_fields(:bag_valid, :fixity_value)
      when [:us, :to_node, :received, :cancelled]
        flag_changed_fields(:bag_valid, :fixity_value)
      when [:us, :to_node, :confirmed, :cancelled]
        flag_changed_fields(:bag_valid, :fixity_value, :fixity_accept)
      when [:us, :to_node, :confirmed, :stored]
        flag_changed_fields(:bag_valid, :fixity_value, :fixity_accept)
      when [:us, :none, :requested, :rejected]
        flag_changed_fields(:bag_valid, :fixity_value, :fixity_accept)
      when [:us, :none, :requested, :received]
        flag_changed_fields(:fixity_accept)
      when [:us, :none, :requested, :confirmed]
      when [:us, :none, :requested, :stored]
      when [:us, :none, :requested, :cancelled]
      when [:us, :none, :received, :confirmed]
        flag_changed_fields(:bag_valid, :fixity_value)
      when [:us, :none, :received, :cancelled]
        flag_changed_fields(:bag_valid, :fixity_value)
      when [:us, :none, :received, :stored]
        flag_changed_fields(:bag_valid, :fixity_value)
      when [:us, :none, :confirmed, :cancelled]
        flag_changed_fields(:bag_valid, :fixity_value, :fixity_accept)
      when [:us, :none, :confirmed, :stored]
        flag_changed_fields(:bag_valid, :fixity_value, :fixity_accept)
      #TODO: From node shouldn't be setting fixity_accept, may want to reject/ignore them
      when [:to_node, :from_node, :requested, :rejected]
        flag_changed_fields(:bag_valid, :fixity_value, :fixity_accept)
      when [:to_node, :from_node, :requested, :received]
        flag_changed_fields(:fixity_accept)
      when [:to_node, :from_node, :requested, :cancelled]
        flag_changed_fields(:fixity_value, :fixity_accept)
      when [:to_node, :from_node, :received, :received]
        flag_changed_fields(:fixity_value, :bag_valid)
      when [:to_node, :from_node, :received, :cancelled]
        flag_changed_fields(:bag_valid, :fixity_value, :fixity_accept)
      when [:to_node, :from_node, :confirmed, :stored]
        flag_changed_fields(:bag_valid, :fixity_value, :fixity_accept)
      when [:to_node, :from_node, :confirmed, :cancelled]
        flag_changed_fields(:bag_valid, :fixity_value, :fixity_accept)
      else
        errors.add(:status, "cannot change from #{status_was}->#{status} when requester==#{from} and the local_node's role is #{role}")
    end
  end

  def flag_changed_fields(*fields)
    fields.each do |field|
      if send(:"#{field}_changed?")
        errors.add(field, "cannot change in this transition.")
      end
    end
  end
end

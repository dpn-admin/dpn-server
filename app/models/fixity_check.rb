# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class FixityCheck < ActiveRecord::Base
  belongs_to :node, inverse_of: :fixity_checks
  belongs_to :bag, inverse_of: :fixity_checks

  ### ActiveModel::Dirty Validations
  validates :fixity_check_id, read_only: true, on: :update
  validates :bag_id,          read_only: true, on: :update
  validates :node_id,         read_only: true, on: :update
  validates :success,         read_only: true, on: :update
  validates :fixity_at,       read_only: true, on: :update
  validates :created_at,      read_only: true, on: :update

  ### Static Validations
  validates :fixity_check_id, presence: true, uniqueness: true,
    format: { with: /\A[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\z/i,
      message: "must be a valid v4 uuid." }
  validates :bag,             presence: true
  validates :node,            presence: true
  validates :success,         inclusion: {in: [false, true]}
  validates :fixity_at,       presence: true
  validates :created_at,      presence: true
  validate :fixity_at_less_than_or_equal_to_created_at
  
  ### Scopes
  scope :created_after, ->(time) { where("created_at < ?", time) unless time.blank? }
  scope :created_before, ->(time) { where("created_at > ?", time) unless time.blank? }
  scope :with_bag_id, ->(id) { where(bag_id: id) unless id.blank? }
  scope :with_node_id, ->(id) { where(node_id: id) unless id.blank? }

  private 
  def fixity_at_less_than_or_equal_to_created_at
    if fixity_at && created_at
      unless fixity_at <= created_at
        errors.add(:fixity_at, "must be <= created_at")
      end
    end
  end
  
end